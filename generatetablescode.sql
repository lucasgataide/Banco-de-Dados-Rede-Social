
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

--trigger que sera disparada quando um insert for feito chamando a procedure trigger_set_timestamp()

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


-- criacao de indexes na tabela users para guardar apenas nome e emails unicos

CREATE UNIQUE INDEX CONCURRENTLY unq_ix_name
ON users (name);
     
alter table users
add constraint uniq_name
unique using index unq_ix_name;
     
CREATE UNIQUE INDEX CONCURRENTLY unq_ix_email
ON users (email);
    
alter table users
add CONSTRAINT uniq_email
UNIQUE USING INDEX unq_ix_email;
	

-- funções

-- DELETAR COMENTARIOS

CREATE OR REPLACE FUNCTION public.deletacomment(id_commentdel integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
      begin
	      
	   WITH RECURSIVE resp AS (  
		SELECT id_comment, array[id_comment] AS path 
		FROM comments   
		WHERE id_comment = id_commentdel  
		UNION ALL 
		SELECT c.id_comment, p.path||c.id_comment  
		FROM comments c 
		JOIN resp p ON p.id_comment = c.id_comment_father)  
	
DELETE FROM comments c WHERE c.id_comment IN (SELECT r.id_comment FROM resp r);
      END;
      $function$
;

-- DELETAR POSTS

CREATE OR REPLACE FUNCTION public.deletapost(id_postdel integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
	declare rec_id_del record;
      begin
	      
	delete from pictures where id_post = id_postdel;
        delete from videos where id_post = id_postdel;
	delete from comments where id_post = id_postdel;
        delete from rel_tag_post where id_post = id_postdel;
        delete from posts where id_post = id_postdel;
      END;
      $function$
;


-- DELETAR USER

CREATE OR REPLACE FUNCTION public.deletauser(id_userdel integer)
 RETURNS void
AS $function$
	 declare rec_id_del_comment record;
 declare rec_id_del_post record;
      begin
	      
	delete from rel_user_user ruu where ruu.id_user = id_userdel;
    
	 for rec_id_del_comment in select id_comment from comments as c where c.id_user = id_userdel
   	 	loop
    		perform deletacomment(rec_id_del_comment.id_comment);
   		end loop;
	   
   	for rec_id_del_post in select id_post from posts as p where p.id_user = id_userdel
   	 	loop
    		perform deletapost(rec_id_del_post.id_post);
   		end loop;
	      
   delete from users u where u.id_user = id_userdel; 
      END;
      $function$
      LANGUAGE plpgsql
;
























