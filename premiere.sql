/*  Banco de dados para o projeto da marmoraria Premieracabamentos. */

create database premiere ;
use premiere;

/* Armazena todas as categorias - Os itens das barras de menu so sistema */
create table categorias (
	id int not null auto_increment primary key,
	nomeCategoria varchar(30) not null unique
);

/* Armazena as subcategorias de categorias - Os itens do dropdowns */
create table subCategorias (
	id int not null auto_increment primary key,
	nomeSubCategoria varchar(30) not null unique,
    categoriaId int ,
    foreign key (categoriaId) references categorias (id) 
);

/* Armazena os itens das subcategorias - O item que irá aparecer na imagem para o cliente. O atributo categoria vem de uma trigger */
create table produtos (
	id int not null auto_increment primary key,
	nomeproduto varchar(40) not null,
	subCategoriaId int,
	foreign key ( subCategoriaId ) references subCategorias ( id ),
	categoriaId int,
	foreign key ( categoriaId ) references categorias ( id )
);

create table valores (
	id int not null auto_increment primary key,
	preco double not null,
    produtoId int unique,
    foreign key ( produtoId ) references produtos ( id ),
	categoriaId int,
    foreign key ( categoriaId ) references produtos ( id ),
	subCategoriaId int,
	foreign key (subCategoriaId) references produtos (id)
);

create table dicas (
id int not null auto_increment primary key,
titulo varchar(30) not null,
descricao longtext not null
);

create table sobreNos (
	id int not null auto_increment primary key,
	titulo varchar(20) not null,
	descricao longtext not null
);


/* Trigger para adicionar id da categoria e subcategoria à tabela de valores */
Delimiter $$
create trigger tr_itens before insert
on valores
for each row
Begin
	
    Declare idcate int;
    Declare idsubcate int;
																
    select categoriaId into idcate from produtos where id = new.produtoId;
	select subCategoriaId into idsubcate from produtos where id = new.produtoId;
    
    set new.categoriaId = idcate;
    set new.subCategoriaId = idsubcate;
    
End $$
Delimiter ;


/* 
	Sempre que uma categoria for excluida, todas as tabelas que herdam seu id, devem ter seus registros referentes a este id excluidos.
    Tabelas que herdam de categorias : ( subcategorias - produtos - valores )
	Isso será feito por uma trigger de forma automatica.
*/

Delimiter $$
	create trigger tr_excluir_dependencias_categorias before delete 
	on categorias
	for each row
	Begin
    
        delete from subCategorias where categoriaId = old.id;
        delete from produtos where categoriaId = old.id;
        delete from valores where categoriaId = old.id;
	
    End $$
Delimiter ;


/* 
	Sempre que uma subCategoria for excluida, todas as tabelas que herdam seu id, devem ter seus registros referentes a este id excluidos.
    Tabelas que herdam de subCategorias : (  produtos - valores )
	Isso será feito por uma trigger de forma automatica.
*/

Delimiter $$
create trigger tr_excluir_dependencias_subCategorias before delete
on subCategorias
for each row
Begin

	delete from produtos where subCategoriaId = old.id;
    delete from valores where subCategoriaId = old.id;
    
End $$
Delimiter ;


/* 
	Toda vez que um item da tabela de produtos for excluido, todas as tabelas que herdam seu id, devem ter seus registros referentes a este id excluidos.
    Tabelas que herdam de produtos : (  valores )
	Isso será feito por uma trigger de forma automatica.
*/
Delimiter $$
create trigger tr_excluir_dependencias_produtos before delete
on produtos
for each row
Begin

	delete from valores where produtoId = old.id;

End $$
Delimiter ;


Delimiter $$
create trigger insere_categoria_produto before insert
on produtos
for each row
Begin

	Declare idcate int;
    select categoriaId into idcate from subcategorias where id = new.subcategoriaId;
    
	set new.categoriaId = idcate;
    
End $$
Delimiter ;



