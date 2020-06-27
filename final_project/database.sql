/* ___________________________________________ Create tables ___________________________________________ */


CREATE TABLE "book" (
	"book_id" serial NOT NULL,
	"ISBN" bigint NOT NULL UNIQUE,
	"version" integer NOT NULL,
	"title" varchar(255) NOT NULL,
	"overview" TEXT,
	"publisher" varchar(255) NOT NULL,
	"publication_date" TIMESTAMP NOT NULL,
	"language" varchar(25) NOT NULL,
	CONSTRAINT "book_pk" PRIMARY KEY ("book_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "book_item" (
	"item_id" serial NOT NULL,
	"is_borrow" bool NOT NULL,
	CONSTRAINT "book_item_pk" PRIMARY KEY ("item_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "author" (
	"author_id" serial NOT NULL,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"biography" TEXT,
	CONSTRAINT "author_pk" PRIMARY KEY ("author_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "author_book" (
	"id" serial NOT NULL,
	"author_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	CONSTRAINT "author_book_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "translator" (
	"translator_id" serial NOT NULL,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	CONSTRAINT "translator_pk" PRIMARY KEY ("translator_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "translator_book" (
	"id" serial NOT NULL,
	"translator_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	CONSTRAINT "translator_book_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "genre" (
	"genre_id" serial NOT NULL,
	"name" varchar(25) NOT NULL,
	CONSTRAINT "genre_pk" PRIMARY KEY ("genre_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "genre_book" (
	"id" serial NOT NULL,
	"genre_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	CONSTRAINT "genre_book_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "customer" (
	"customer_id" serial NOT NULL,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"rgistration_date" DATE NOT NULL,
	"email" varchar(255) NOT NULL,
	"phone_number" varchar(15) NOT NULL,
	"address" TEXT NOT NULL,
	CONSTRAINT "customer_pk" PRIMARY KEY ("customer_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "borrow_status" (
	"status_id" serial NOT NULL,
	"item_id" integer NOT NULL,
	"customer_id" integer NOT NULL,
	"borrowed_date" TIMESTAMP NOT NULL,
	"due_date" TIMESTAMP NOT NULL,
	"is_overdue" bool NOT NULL,
	"return_date" TIMESTAMP,
	CONSTRAINT "borrow_status_pk" PRIMARY KEY ("status_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "temp_log" (
	"log_id" serial NOT NULL,
	"table_name" varchar(15) NOT NULL,
	"event" varchar(6) NOT NULL,
	"record_pk" integer NOT NULL,
	CONSTRAINT "temp_log_pk" PRIMARY KEY ("log_id")
) WITH (
  OIDS=FALSE
);


/* ___________________________________________ Add foreign keys ___________________________________________ */

ALTER TABLE "book_item" ADD CONSTRAINT "book_item_fk0" FOREIGN KEY ("item_id") REFERENCES "book"("book_id");


ALTER TABLE "author_book" ADD CONSTRAINT "author_book_fk0" FOREIGN KEY ("author_id") REFERENCES "author"("author_id");
ALTER TABLE "author_book" ADD CONSTRAINT "author_book_fk1" FOREIGN KEY ("book_id") REFERENCES "book"("book_id");


ALTER TABLE "translator_book" ADD CONSTRAINT "translator_book_fk0" FOREIGN KEY ("translator_id") REFERENCES "translator"("translator_id");
ALTER TABLE "translator_book" ADD CONSTRAINT "translator_book_fk1" FOREIGN KEY ("book_id") REFERENCES "book"("book_id");


ALTER TABLE "genre_book" ADD CONSTRAINT "genre_book_fk0" FOREIGN KEY ("genre_id") REFERENCES "genre"("genre_id");
ALTER TABLE "genre_book" ADD CONSTRAINT "genre_book_fk1" FOREIGN KEY ("book_id") REFERENCES "book"("book_id");


ALTER TABLE "borrow_status" ADD CONSTRAINT "borrow_status_fk0" FOREIGN KEY ("item_id") REFERENCES "book_item"("item_id");
ALTER TABLE "borrow_status" ADD CONSTRAINT "borrow_status_fk1" FOREIGN KEY ("customer_id") REFERENCES "customer"("customer_id");


/* ___________________________________________ book table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_book_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('book','INSERT',NEW.book_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER book_insert
AFTER INSERT
ON book
FOR EACH ROW
EXECUTE PROCEDURE log_book_insert();



CREATE OR REPLACE FUNCTION log_book_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('book','UPDATE',NEW.book_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER book_update
AFTER UPDATE
ON book
FOR EACH ROW
EXECUTE PROCEDURE log_book_update();



CREATE OR REPLACE FUNCTION log_book_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('book','DELETE',OLD.book_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER book_delete
AFTER DELETE
ON book
FOR EACH ROW
EXECUTE PROCEDURE log_book_delete();


/* ___________________________________________ author table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_author_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('author','INSERT',NEW.author_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER author_insert
AFTER INSERT
ON author
FOR EACH ROW
EXECUTE PROCEDURE log_author_insert();



CREATE OR REPLACE FUNCTION log_author_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('author','UPDATE',NEW.author_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER author_update
AFTER UPDATE
ON author
FOR EACH ROW
EXECUTE PROCEDURE log_author_update();



CREATE OR REPLACE FUNCTION log_author_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('author','DELETE',OLD.author_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER author_delete
AFTER DELETE
ON author
FOR EACH ROW
EXECUTE PROCEDURE log_author_delete();


/* ___________________________________________ author_book table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_author_book_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('author_book','INSERT',NEW.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER author_book_insert
AFTER INSERT
ON author_book
FOR EACH ROW
EXECUTE PROCEDURE log_author_book_insert();



CREATE OR REPLACE FUNCTION log_author_book_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('author_book','UPDATE',NEW.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER author_book_update
AFTER UPDATE
ON author_book
FOR EACH ROW
EXECUTE PROCEDURE log_author_book_update();



CREATE OR REPLACE FUNCTION log_author_book_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('author_book','DELETE',OLD.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER author_book_delete
AFTER DELETE
ON author_book
FOR EACH ROW
EXECUTE PROCEDURE log_author_book_delete();


/* ___________________________________________ translator table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_translator_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('translator','INSERT',NEW.translator_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER translator_insert
AFTER INSERT
ON translator
FOR EACH ROW
EXECUTE PROCEDURE log_translator_insert();



CREATE OR REPLACE FUNCTION log_translator_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('translator','UPDATE',NEW.translator_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER translator_update
AFTER UPDATE
ON translator
FOR EACH ROW
EXECUTE PROCEDURE log_translator_update();



CREATE OR REPLACE FUNCTION log_translator_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('translator','DELETE',OLD.translator_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER translator_delete
AFTER DELETE
ON translator
FOR EACH ROW
EXECUTE PROCEDURE log_translator_delete();


/* ___________________________________________ translator_book table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_translator_book_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('translator_book','INSERT',NEW.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER translator_book_insert
AFTER INSERT
ON translator_book
FOR EACH ROW
EXECUTE PROCEDURE log_translator_book_insert();



CREATE OR REPLACE FUNCTION log_translator_book_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('translator_book','UPDATE',NEW.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER translator_book_update
AFTER UPDATE
ON translator_book
FOR EACH ROW
EXECUTE PROCEDURE log_translator_book_update();



CREATE OR REPLACE FUNCTION log_translator_book_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('translator_book','DELETE',OLD.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER translator_book_delete
AFTER DELETE
ON translator_book
FOR EACH ROW
EXECUTE PROCEDURE log_translator_book_delete();


/* ___________________________________________ genre table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_genre_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('genre','INSERT',NEW.genre_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER genre_insert
AFTER INSERT
ON genre
FOR EACH ROW
EXECUTE PROCEDURE log_genre_insert();



CREATE OR REPLACE FUNCTION log_genre_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('genre','UPDATE',NEW.genre_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER genre_update
AFTER UPDATE
ON genre
FOR EACH ROW
EXECUTE PROCEDURE log_genre_update();



CREATE OR REPLACE FUNCTION log_genre_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('genre','DELETE',OLD.genre_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER genre_delete
AFTER DELETE
ON genre
FOR EACH ROW
EXECUTE PROCEDURE log_genre_delete();


/* ___________________________________________ genre_book table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_genre_book_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('genre_book','INSERT',NEW.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER genre_book_insert
AFTER INSERT
ON genre_book
FOR EACH ROW
EXECUTE PROCEDURE log_genre_book_insert();



CREATE OR REPLACE FUNCTION log_genre_book_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('genre_book','UPDATE',NEW.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER genre_book_update
AFTER UPDATE
ON genre_book
FOR EACH ROW
EXECUTE PROCEDURE log_genre_book_update();



CREATE OR REPLACE FUNCTION log_genre_book_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('genre_book','DELETE',OLD.id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER genre_book_delete
AFTER DELETE
ON genre_book
FOR EACH ROW
EXECUTE PROCEDURE log_genre_book_delete();


/* ___________________________________________ book_item table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_book_item_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('book_item','INSERT',NEW.item_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER book_item_insert
AFTER INSERT
ON book_item
FOR EACH ROW
EXECUTE PROCEDURE log_book_item_insert();



CREATE OR REPLACE FUNCTION log_book_item_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('book_item','UPDATE',NEW.item_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER book_item_update
AFTER UPDATE
ON book_item
FOR EACH ROW
EXECUTE PROCEDURE log_book_item_update();



CREATE OR REPLACE FUNCTION log_book_item_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('book_item','DELETE',OLD.item_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER book_item_delete
AFTER DELETE
ON book_item
FOR EACH ROW
EXECUTE PROCEDURE log_book_item_delete();


/* ___________________________________________ borrow_status table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_borrow_status_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('borrow_status','INSERT',NEW.status_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER borrow_status_insert
AFTER INSERT
ON borrow_status
FOR EACH ROW
EXECUTE PROCEDURE log_borrow_status_insert();



CREATE OR REPLACE FUNCTION log_borrow_status_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('borrow_status','UPDATE',NEW.status_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER borrow_status_update
AFTER UPDATE
ON borrow_status
FOR EACH ROW
EXECUTE PROCEDURE log_borrow_status_update();



CREATE OR REPLACE FUNCTION log_borrow_status_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('borrow_status','DELETE',OLD.status_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER borrow_status_delete
AFTER DELETE
ON borrow_status
FOR EACH ROW
EXECUTE PROCEDURE log_borrow_status_delete();


/* ___________________________________________ customer table triggers ___________________________________________ */


CREATE OR REPLACE FUNCTION log_customer_insert()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('customer','INSERT',NEW.customer_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER customer_insert
AFTER INSERT
ON customer
FOR EACH ROW
EXECUTE PROCEDURE log_customer_insert();



CREATE OR REPLACE FUNCTION log_customer_update()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('customer','UPDATE',NEW.customer_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER customer_update
AFTER UPDATE
ON customer
FOR EACH ROW
EXECUTE PROCEDURE log_customer_update();



CREATE OR REPLACE FUNCTION log_customer_delete()
RETURNS trigger AS
$BODY$
BEGIN
    INSERT INTO temp_log(table_name,event,record_pk)
    VALUES('customer','DELETE',OLD.customer_id);
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER customer_delete
AFTER DELETE
ON customer
FOR EACH ROW
EXECUTE PROCEDURE log_customer_delete();