/* ___________________________________________ Create tables ___________________________________________ */


CREATE TABLE "translator" (
	"translator_id" integer NOT NULL UNIQUE,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "translator_pk" PRIMARY KEY ("translator_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "translator_book" (
	"id" integer NOT NULL UNIQUE,
	"translator_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "translator_book_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "book_item" (
	"item_id" integer NOT NULL UNIQUE,
	"is_borrow" bool NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "book_item_pk" PRIMARY KEY ("item_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "borrow_status" (
	"status_id" integer NOT NULL UNIQUE,
	"item_id" integer NOT NULL,
	"customer_id" integer NOT NULL,
	"borrowed_date" TIMESTAMP NOT NULL,
	"due_date" TIMESTAMP NOT NULL,
	"is_overdue" bool NOT NULL,
	"return_date" TIMESTAMP,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "borrow_status_pk" PRIMARY KEY ("status_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "customer" (
	"customer_id" integer NOT NULL UNIQUE,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"registration_date" TIMESTAMP NOT NULL,
	"email" varchar(255) NOT NULL,
	"phone_number" varchar(15) NOT NULL,
	"address" TEXT NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "customer_pk" PRIMARY KEY ("customer_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "genre" (
	"genre_id" integer NOT NULL UNIQUE,
	"name" varchar(25) NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "genre_pk" PRIMARY KEY ("genre_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "genre_book" (
	"id" integer NOT NULL UNIQUE,
	"genre_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "genre_book_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "book" (
	"book_id" integer NOT NULL UNIQUE,
	"ISBN" bigint NOT NULL UNIQUE,
	"version" integer NOT NULL,
	"title" varchar(255) NOT NULL,
	"overview" TEXT,
	"publisher" varchar(255) NOT NULL,
	"publication_date" TIMESTAMP NOT NULL,
	"language" varchar(25) NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "book_pk" PRIMARY KEY ("book_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "author_book" (
	"id" integer NOT NULL UNIQUE,
	"author_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "author_book_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "author" (
	"author_id" integer NOT NULL UNIQUE,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"biography" TEXT,
	"created_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "author_pk" PRIMARY KEY ("author_id")
) WITH (
  OIDS=FALSE
);


/* ___________________________________________ Add foreign keys ___________________________________________ */


ALTER TABLE "translator_book" ADD CONSTRAINT "translator_book_fk0" FOREIGN KEY ("translator_id") REFERENCES "translator"("translator_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "translator_book" ADD CONSTRAINT "translator_book_fk1" FOREIGN KEY ("book_id") REFERENCES "book"("book_id") ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "book_item" ADD CONSTRAINT "book_item_fk0" FOREIGN KEY ("item_id") REFERENCES "book"("book_id") ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "borrow_status" ADD CONSTRAINT "borrow_status_fk0" FOREIGN KEY ("item_id") REFERENCES "book_item"("item_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "borrow_status" ADD CONSTRAINT "borrow_status_fk1" FOREIGN KEY ("customer_id") REFERENCES "customer"("customer_id") ON UPDATE NO ACTION ON DELETE NO ACTION;



ALTER TABLE "genre_book" ADD CONSTRAINT "genre_book_fk0" FOREIGN KEY ("genre_id") REFERENCES "genre"("genre_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "genre_book" ADD CONSTRAINT "genre_book_fk1" FOREIGN KEY ("book_id") REFERENCES "book"("book_id") ON UPDATE NO ACTION ON DELETE NO ACTION;


ALTER TABLE "author_book" ADD CONSTRAINT "author_book_fk0" FOREIGN KEY ("author_id") REFERENCES "author"("author_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "author_book" ADD CONSTRAINT "author_book_fk1" FOREIGN KEY ("book_id") REFERENCES "book"("book_id") ON UPDATE NO ACTION ON DELETE NO ACTION;


/* ___________________________________________ Create history tables ___________________________________________ */


CREATE TABLE "book_history" (
	"book_id" integer NOT NULL UNIQUE,
	"ISBN" bigint NOT NULL UNIQUE,
	"version" integer NOT NULL,
	"title" varchar(255) NOT NULL,
	"overview" TEXT,
	"publisher" varchar(255) NOT NULL,
	"publication_date" TIMESTAMP NOT NULL,
	"language" varchar(25) NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "book_history_pk" PRIMARY KEY ("book_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "author_book_history" (
	"id" integer NOT NULL UNIQUE,
	"author_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "author_book_history_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "translator_book_history" (
	"id" integer NOT NULL UNIQUE,
	"translator_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "translator_book_history_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "book_item_history" (
	"item_id" integer NOT NULL UNIQUE,
	"is_borrow" bool NOT NULL,
	"created_at" TIMESTAMP NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "book_item_history_pk" PRIMARY KEY ("item_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "genre_book_history" (
	"id" integer NOT NULL UNIQUE,
	"genre_id" integer NOT NULL,
	"book_id" integer NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "genre_book_history_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "borrow_status_history" (
	"status_id" integer NOT NULL UNIQUE,
	"item_id" integer NOT NULL,
	"customer_id" integer NOT NULL,
	"borrowed_date" TIMESTAMP NOT NULL,
	"due_date" TIMESTAMP NOT NULL,
	"is_overdue" bool NOT NULL,
	"return_date" TIMESTAMP,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "borrow_status_history_pk" PRIMARY KEY ("status_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "translator_history" (
	"translator_id" integer NOT NULL UNIQUE,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "translator_history_pk" PRIMARY KEY ("translator_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "author_history" (
	"author_id" integer NOT NULL UNIQUE,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"biography" TEXT,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "author_history_pk" PRIMARY KEY ("author_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "customer_history" (
	"customer_id" integer NOT NULL UNIQUE,
	"first_name" varchar(35) NOT NULL,
	"last_name" varchar(35) NOT NULL,
	"birth_date" DATE NOT NULL,
	"registration_date" TIMESTAMP NOT NULL,
	"email" varchar(255) NOT NULL,
	"phone_number" varchar(15) NOT NULL,
	"address" TEXT NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "customer_history_pk" PRIMARY KEY ("customer_id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "genre_history" (
	"genre_id" integer NOT NULL UNIQUE,
	"name" varchar(25) NOT NULL,
	"event" varchar(6) NOT NULL,
	"occurred_at" TIMESTAMP DEFAULT NOW(),
	CONSTRAINT "genre_history_pk" PRIMARY KEY ("genre_id")
) WITH (
  OIDS=FALSE
);
