import psycopg2
from datetime import datetime

class Etl:
    def __init__(self):
        pass 


    def create_db_connection(self):
        self.conn1 = None
        self.conn2 = None
        status = 1
        try:
            # connect to the PostgreSQL server
            print('Connecting to the PostgreSQL database...')
            self.conn1 = psycopg2.connect(host='localhost', port='5432', dbname='library', user='postgres', password='7221974')
            self.conn2 = psycopg2.connect(host='localhost', port='5432', dbname='warehouse', user='postgres', password='7221974')
            # create a cursor
            self.cur1 = self.conn1.cursor()
            self.cur2 = self.conn2.cursor()
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            status = 0
        if status == 1:
            print('Connected!\n')


    def close_db_connection(self):
        # close the communication with the PostgreSQL
        if self.conn1 is not None:
            self.conn1.close()
            print('Library Database connection closed.')
        if self.conn2 is not None:
            self.conn2.close()
            print('Data Warehouse connection closed.')


    def extract(self):
        # get tables and primery keys names from main database
        sql = '''
            SELECT  kcu.table_name, kcu.column_name as pk_column
            FROM    information_schema.table_constraints tco
                    JOIN information_schema.key_column_usage kcu
                    ON kcu.constraint_name = tco.constraint_name
            WHERE   tco.constraint_type = 'PRIMARY KEY';
        '''
        self.cur1.execute(sql)
        table_pk = self.cur1.fetchall()
        table_pk = {t: pk for (t, pk) in table_pk}

        # get tables dependecies 
        # (table_name, column_name, foreign_table_name, foreign_column_name)
        sql = '''
            SELECT
                tc.table_name,
                kcu.table_name,
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM
                information_schema.table_constraints AS tc
                JOIN information_schema.key_column_usage AS kcu
                ON tc.constraint_name = kcu.constraint_name
                AND tc.table_schema = kcu.table_schema
                JOIN information_schema.constraint_column_usage AS ccu
                ON ccu.constraint_name = tc.constraint_name
                AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY';
        '''
        self.cur1.execute(sql)
        dependecies = self.cur1.fetchall()

        # get temp log table data
        sql = 'SELECT * FROM temp_log'
        self.cur1.execute(sql)
        temp_log = self.cur1.fetchall()

        return temp_log, table_pk, dependecies

    
    def transform(self, temp_log, table_pk, dependecies):
        # queries: list of query to apply on warehouse in load step
        queries = list()

        for log in temp_log:
            # fetch record by table name and pk from main database
            sql = f'SELECT * FROM {log[1]} WHERE {table_pk[log[1]]} = {log[3]};'
            self.cur1.execute(sql)
            record = self.cur1.fetchone()
            record = Etl.refactor_values(record)

            # create query base on event in temp log table
            if log[2] == 'INSERT':
                queries.append(f'INSERT INTO {log[1]} VALUES {record};')

            elif log[2] == 'DELETE':
                # solve dependencies
                for d in dependecies:
                    if d[2] == log[2]:
                        sql = (f'SELECT * FROM {d[0]} WHERE {d[1]} = {log[3]};')
                        self.cur2.execute(sql)
                        old_record = self.cur1.fetchone()
                        old_record += ('DELETE',)   
                        queries.append(f'INSERT INTO {d[0]}_history VALUES {old_record};')
                        queries.append(f'DELETE * FROM {d[0]} WHERE {d[1]} = {log[3]};')
                # fetch old record by table name and pk from warehouse
                sql = (f'SELECT * FROM {log[1]} WHERE {table_pk[log[1]]} = {log[3]};')
                self.cur2.execute(sql)
                old_record = self.cur1.fetchone()
                old_record += ('DELETE',)   
                # this query move record from primary table to history table (in warehouse)
                queries.append(f'INSERT INTO {log[1]}_history VALUES {old_record};')
                # then this query delete old record from primary table (in warehouse)
                queries.append(f'DELETE FROM {log[1]} WHERE {table_pk[log[1]]} = {log[3]};')

            elif log[2] == 'UPDATE':
                # solve dependencies
                for d in dependecies:
                    if d[2] == log[2]:
                        sql = f'SELECT * FROM {d[0]} WHERE {d[1]} = {log[3]}'
                        self.cur2.execute(sql)
                        old_record = self.cur1.fetchone()
                        old_record += ('UPDATE',)
                        queries.append(f'INSERT INTO {d[0]}_history VALUES {old_record};')
                        queries.append(f'DELETE {d[0]} WHERE {d[1]} = {log[3]};')
                        record = self.cur2.execute(f'SELECT * FROM {d[0]} WHERE id = {log[3]};')
                        queries.append(f'INSERT INTO {d[0]} VALUES {record};')
                # fetch old record by table name and pk from warehouse
                sql = f'SELECT * FROM {log[1]} WHERE {table_pk[log[1]]} = {log[3]};'
                self.cur2.execute(sql)
                old_record = self.cur1.fetchone()
                old_record += ('UPDATE',)
                # this query move record from primary table to history table (in warehouse)
                queries.append(f'INSERT INTO {log[1]}_history VALUES {old_record}')
                # this section update old record in warehouse
                # (first delete old record then insert updated record)
                queries.append(f'DELETE {log[1]} WHERE {table_pk[log[1]]} = {log[3]};')
                queries.append(f'INSERT INTO {log[1]} VALUES {record};')
        
        return queries


    def load(self, queries):
        for q in queries:
            self.cur2.execute(q)
            self.cur2.commit()


    @staticmethod
    def refactor_values(record):
        for field in record:
            # convert None to NULL
            if field is None:
                i = record.index(field)
                record = list(record)
                record[i] = ''
                record = tuple(record)
            # convert datetime object to timestamp
            if isinstance(field, datetime):
                i = record.index(field)
                record = list(record)
                record[i] = f'{str(field)}'
                record = tuple(record)
        return record
            

if __name__ == '__main__':
    etl = Etl()
    etl.create_db_connection()
    # Extract
    tmp_log, t_pk, dep = etl.extract()
    # Transform
    queries = etl.transform(tmp_log, t_pk, dep)
    # Load
    etl.load(queries)
    etl.close_db_connection()