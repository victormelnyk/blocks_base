"D:\Programs\PostgreSQL SQL Manager\5.0.0.3\Dump\pg_dump84.exe" -h localhost -p 5432 -U postgres -F p -s -E UTF8 -v -f full.sql blocks
D:\Programs\CommentsDelete\CommentsDelete.exe full.sql .sql

"D:\Programs\PostgreSQL SQL Manager\5.0.0.3\Dump\pg_dump84.exe" -h localhost -p 5432 -U postgres -F p -a --disable-triggers -E UTF8 --inserts --column-inserts -v -f data_full.sql blocks
D:\Programs\CommentsDelete\CommentsDelete.exe data_full.sql data.sql

DEL *_full.sql, full.sql