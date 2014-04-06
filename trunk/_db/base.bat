.bat

"v:\Programs\PostgreSQL SQL Manager\5.0.0.3\Dump\pg_dump84.exe" -h localhost -p 5432 -U postgres -F p -s -E UTF8 -O -n """df""" -v -f ..\..\blocks_base\_db\df_full.sql blocks
v:\Programs\CommentsDelete\CommentsDelete.exe ..\..\blocks_base\_db\df_full.sql ..\..\blocks_base\_db\df.sql

"v:\Programs\PostgreSQL SQL Manager\5.0.0.3\Dump\pg_dump84.exe" -h localhost -p 5432 -U postgres -F p -s -E UTF8 -O -n """doc""" -v -f ..\..\blocks_base\_db\doc_full.sql blocks
v:\Programs\CommentsDelete\CommentsDelete.exe ..\..\blocks_base\_db\doc_full.sql ..\..\blocks_base\_db\doc.sql