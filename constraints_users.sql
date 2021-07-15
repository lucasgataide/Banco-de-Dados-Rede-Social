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
	