
----- tabela users

--criacao da procedure que vai ser chamada para inserir a data automaticamente
create or replace function trigger_set_timestamp()
returns trigger as $$
begin
	new.create_date = now();
	return new;
end;
$$ language plpgsql;

--tabela usuario
create table if not exists users(
	id_user SERIAL primary key,
	name VARCHAR (50) not null,
	url_pic_perfil text,
	email VARCHAR (50) not null,
	password VARCHAR (20) not null,
	description text,
	create_date TIMESTAMP not null default now()
);

--trigger que sera disparada quando um insert for feito chamando a procedure
create trigger set_timestamp
before insert on users
for each row
execute procedure trigger_set_timestamp();

-------------------
--tabela rel_user_user

create table rel_user_user(
	id_user int not null,
	id_follow int not null,
	foreign key (id_user) references users (id_user),
	foreign key (id_follow) references users (id_user)
);

-----------------
--tabela posts

create table posts(
	id_post serial primary key,
	id_user int not null,
	title varchar(50),
	text text,
	create_date timestamp not null default now(),
	foreign key (id_user) references users (id_user)
);

create trigger set_timestamp
before insert on posts
for each row
execute procedure trigger_set_timestamp();

---------------------
-- tabela tags

create table tags(
	id_tag serial primary key,
	name varchar(50)
);

------------------------
-- tabela rel_tags_post

create table rel_tag_post(
	id_tag int not null,
	id_post int not null,
	foreign key (id_tag) references tags (id_tag),
	foreign key (id_post) references posts (id_post)
);

----------------
--- tabela videos

create table videos(
	id_video serial primary key,
	id_post int not null,
	url_video text,
	foreign key (id_post) references posts (id_post)
);

-------------
-- tabela fotos

create table pictures(
	id_picture serial primary key,
	id_post int not null,
	url_picture text,
	foreign key (id_post) references posts (id_post)
);

---------------
--- tabela comentarios

create table comments(
	id_comment serial primary key,
	id_user int not null,
	id_post int not null,
	id_comment_father int,
	text text,
	create_date timestamp not null default now(),
	foreign key (id_user) references users (id_user),
	foreign key (id_post) references posts (id_post),
	foreign key (id_comment_father) references comments (id_comment)
);

create trigger set_timestamp
before insert on comments
for each row
execute procedure trigger_set_timestamp();































