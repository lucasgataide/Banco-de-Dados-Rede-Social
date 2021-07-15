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
AS $function$
	declare rec_id_del record;
      begin
	      
	    delete from pictures where id_post = id_postdel;
        delete from videos where id_post = id_postdel;
       
	    for rec_id_del in select id_comment from comments as c where c.id_post = id_postdel
   	 	loop
    		perform deletacomment(rec_id_del.id_comment);
   		end loop;
   	
        delete from rel_tag_post where id_post = id_postdel;
        delete from posts where id_post = id_postdel;
      END;
      $function$
      LANGUAGE plpgsql
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

-- ADICIONAR TAGS

CREATE OR REPLACE FUNCTION public.adicionatag(id_postbanco integer, id_tagadd integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
      begin
	      
	   declare teste
       declare tagbanco integer;
       if(select count(*) from tags where id_tag = id_tagadd) > 0
		begin 
			inser into testedebug values (666);
		end
      END;
      $function$
;