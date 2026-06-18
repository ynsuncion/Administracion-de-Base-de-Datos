-- vistas: tabla virtual sobre las que se pueden realizar consultas

CREATE VIEW librosautores
AS
SELECT	a.au_id,
		a.au_fname,
		a.au_lname,
		a.state,
		t.title_id,
		t.type,
		t.price,
		t.pub_id

FROM	authors a
INNER JOIN titleauthor ta
ON		a.au_id=ta.au_id
INNER JOIN titles t
ON		ta.title_id=t.title_id

select * from librosautores

ALTER VIEW librosautores
AS
SELECT	a.au_id,
		a.au_fname,
		a.au_lname,
		t.title_id,
		t.type,
		t.price,
		
FROM	authors a
INNER JOIN titleauthor ta
ON		a.au_id=ta.au_id
INNER JOIN titles t
ON		ta.title_id=t.title_id



select * from librosautores

drop view librosautores