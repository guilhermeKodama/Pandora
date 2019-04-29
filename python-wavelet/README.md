##LINKS IMPORTANTES

<!-- Biblioteca interativa cardivascular -->
http://watchlearnlive.heart.org/CVML_Player.php?moduleSelect=arrhyt

<!-- Ferramenta visual de visualização de ECGs -->
http://physionet.org/lightwave/

<!-- Detalhes de todos os significados das anotações e simbolos que aparecem nos arquivos baixados -->
https://www.physionet.org/physiobank/annotations.shtml

<!-- Detalhes gerais da universidade, do BD e dos arquivos contidos no BD -->
https://physionet.org/physiobank/database/
https://physionet.org/physiobank/database/<codigo do database>

<!-- Ferramenta visual de exportação -->
http://www.physionet.org/cgi-bin/atm/ATM?


<!-- Tutorial de donwload dos principais sinais e anotaçÕes do physionet em formatod de texto -->
https://physionet.org/tutorials/physiobank-text.shtml

1 - rdsamp
	<!-- Ferramenta utilizada para baixar os exemplos das bases de de dados -->

2 - rann
	<!-- Ferramenta utilizada para baixar as anotações dos experimentos,
	ou seja, ele mostra onde ocorreu eventos importantes nas amostras como as arritmias -->

3 - wfdbcat
	<!-- Ferramenta utilizada para baixar um arquivo que contém todos os nomes dos ECGs contidos naquele BD-->
	wfdbcat <codigo do database>/RECORDS > records.csv
	<!-- Baixa e salva em CSV -->

rdann -r cudb/cu01 -a atr -f 5:10 -t 10:30 -v > cu01.csv
<!-- esse comando vai pegar todas as anotações desse data set, entre um devido intervalo de tempo (-f ; -t), vai colocar os cabeçalhos do que é cada coluna (-v ), e vai colocar as anotações dos pesquisadores junto com o dataset (-a), por exemplo quando ocorre uma arritmia -->


## POR QUE ISSO É IMPORTANTE?
utilizando o comando rdann nós conseguimos os metadados que precisamos para depois chamar
o comando rdsamp e conseguir apenas as partes do streamming que nos interessam de acordo
com as anotações dos pesquisadores


## MANDINGAS
rdann -r cudb/cu01 -a atr -v -p + [ ] > cu01.csv (-p especifica o tipo que queremos)

<!-- Outrs links de outros recursos -->
https://www.physionet.org/other-links.shtml
https://www.physionet.org/physiobank/other.shtml

http://electrogram.com/resources.html

http://electrogram.com/browser.new/default.asp?volume=Volume%20One

http://www.ecglibrary.com/ecghome.php

<!-- Desafios de cardiologia do Physitonet/Computação -->
https://www.physionet.org/challenge/

<!-- Pilítica de cópia do Physionet -->
https://www.physionet.org/copying.shtml