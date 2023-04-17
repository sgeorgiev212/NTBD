use example;

create table object_info (
  id int primary key identity(1,1),
  objectID int,
  deactive datetime,
  content varchar(255),
);


create table object_info_backup (
   id int primary key,
   objectID int,
   deactive dateTime,
   content varchar(255)
);

CREATE TRIGGER validateDataAfterUpdate
ON object_info
AFTER UPDATE
AS
BEGIN

DECLARE @CurrentID int, @ObjectID varchar(255), @Content varchar(255)
SELECT @CurrentID = id from deleted
SELECT @ObjectID = objectID from deleted
SELECT @Content = content from inserted
BEGIN TRANSACTION 

update object_info set deactive = CURRENT_TIMESTAMP where id = @CurrentID;
insert into object_info(objectID, deactive, content) values (@ObjectID, null, @Content);
SAVE TRANSACTION DataValidation;

if exists(SELECT count(*) FROM object_info where objectID = @ObjectID and deactive <= DATEADD(mm, -6, GETDATE())) 
BEGIN
  insert into object_info_backup(id, objectID, deactive, content) SELECT * FROM object_info where objectID = @ObjectID and deactive <= DATEADD(mm, -6, GETDATE())
  delete from object_info where objectID = @ObjectID and deactive <= DATEADD(mm, -6, GETDATE()) and id != @CurrentID
END
IF @@ERROR <> 0 ROLLBACK TRANSACTION DataValidation;
SAVE TRANSACTION DataValidation;
  

DECLARE @cnt INT;
set @cnt = (SELECT count(*) FROM object_info where objectID = @ObjectID);
if (@cnt>5)
BEGIN
  insert into object_info_backup(id, objectID, deactive, content) SELECT * FROM object_info where objectID = @ObjectID and id != @CurrentID
  delete from object_info where objectID = @ObjectID and content != @Content
END
IF @@ERROR <> 0 ROLLBACK TRANSACTION DataValidation;
COMMIT TRANSACTION;

END

select * from object_info;

select * from object_info_backup;

insert into object_info(objectID, deactive, content) values (10, null, 'test4');

insert into object_info(objectID, deactive, content) values (10, '2022-04-09 13:50:24.160', 'test8');

update object_info set content = 'some text' where id = 1;

truncate table object_info;

truncate table object_info_backup;

drop trigger validateDataAfterUpdate;