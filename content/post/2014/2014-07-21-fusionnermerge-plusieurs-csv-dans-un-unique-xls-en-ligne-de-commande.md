---
title: Fusionner plusieurs CSV dans un unique XLS en ligne de commande
authors:
  - zwindler
type: post
date: 2014-07-21T14:53:01+00:00
url: /2014/07/21/fusionnermerge-plusieurs-csv-dans-un-unique-xls-en-ligne-de-commande/
image: /2014/07/pythonlogo.jpg
sharing_disabled:
  - 1
categories:
  - Script
  - systeme
tags:
  - command line
  - csv
  - excel
  - fusion
  - ligne de commande
  - Linux
  - merge
  - pyExcelerator
  - spreadsheets
  - xls

---
En voulant créer mes propres rapports à partir de mes bases MySQL NDO (nagios), je me suis retrouvé avec un problème : comment consolider les données de manière à avoir un rapport clair (et pas de lignes et des lignes à la mode CSV).

Comme il ne s’agissait pas de valeurs chiffrées à intégrer à des graphiques, je suis parti dans l’idée de consolider mes différents rapports dans un fichier MS Excel, notamment pour pouvoir trier les données dans les onglets séparés (les rapports traitent de sujets différents que l’on ne peut regrouper dans une seule et même vue).

Je me suis vite rendu compte que ce n’était pas aussi facile que cela !

**Générer des CSV à partir de MySQL**

La première étape a donc été dans mon cas de commencer par récupérer des CSV à partir des données de MySQL. Ça, c’était assez simple dans le cas de requêtes sans UNION, il suffit d’ajouter à la fin de la requêtes les lignes suivantes :

```
INTO OUTFILE 'output.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY 'n';
```


Dans le cas du UNION, la petit spécificité qu’il faut savoir est qu’on doit insérer ces 3 lignes dans le dernier bloc SELECT, et non pas tout à la fin. Toute la sélection sera néanmoins bien prise en compte.

**Générer un XLS à partir d’un fichier CSV**

J’ai trouvé plusieurs solutions en perl et en php permettant d’installer des extensions capables de gérer les fichiers CSV et les convertir en fichier Excel, mais l’extension qui m’a le plus plu est sans aucun doute l’extension pyExcelerator en Python.  
Première chose, il faut récupérer la dernière version sur pipy ([pyExcelerator sur pypi](https://pypi.python.org/pypi/pyExcelerator)), la décompacter puis l’installer. Pour ceux qui ne se souviendraient plus :

```
tar xjf pyexcelerator-0.6.4.1.tar.bz2
python setup.py install
```


Une fois le module installé, on peut faire appel à lui comme n’importe quel autre dans le shell python (ou dans les scripts).

Si jamais générer **un** seul fichier **XLS** pour **un** seul fichier **CSV** vous suffit, je vous recommande alors le script disponible sur l’article suivant

* [sujitpal.blogspot.fr](http://sujitpal.blogspot.fr/2007/02/python-script-to-convert-csv-files-to.html)

En revanche, si comme moi vous souhaitez un script qui permet dans **un** même fichier **XLS** de consolider **plusieurs** fichiers **CSV** (un par onglet) il faut aller plus loin...

**Générer un XLS à partir de plusieurs fichiers CSV**

...mais pas beaucoup plus ! OUF !

J’ai fais l’exercice pour vous et j’ai modifié le script de Sujit Pal sur son blog _Salmon Run_ pour qu’il accepte en entrée autant de fichiers CSV que vous le souhaitez (il n’y a pas une grosse différence, il ne manquait pas grand chose). Les fichiers CSV auront chacun leur propre onglet.

Pour plus de facilité [j’ai posté le script sur Github à cette adresse](https://github.com/zwindler/csv_to_excel).

```
#!/usr/bin/python
#!/usr/bin/python
# Tool to convert CSV files (with configurable delimiter and text wrap
# character) to Excel spreadsheets.
################################################################################
# Found on http://sujitpal.blogspot.fr/2007/02/python-script-to-convert-csv-files-to.html
# Requires setup.py install of pyExcelerator found on
# https://pypi.python.org/pypi/pyExcelerator
# Modified to concat csv files in different sheets
################################################################################
import string
import sys
import getopt
import re
import os
import os.path
import csv
from pyExcelerator import *
 
def usage():
  ''' Display the usage '''
  print 'Usage:' + sys.argv[0] + ' [OPTIONS] csvfile'
  print 'OPTIONS:'
  print '--title|-t: If set, the first line is the title line'
  print '--lines|-l n: Split output into files of n lines or less each'
  print '--sep|-s c [def:,] : The character to use for field delimiter'
  print '--output|o: output file name/pattern, default: output.xls'
  print '--help|h: print this information'
  sys.exit(2)
 
def writeExcelHeader(worksheet, titleCols):
  ''' Write the header line into the worksheet '''
  cno = 0
  for titleCol in titleCols:
    worksheet.write(0, cno, titleCol)
    cno = cno + 1
 
def writeExcelRow(worksheet, lno, columns):
  ''' Write a non-header row into the worksheet '''
  cno = 0
  for column in columns:
    worksheet.write(lno, cno, column)
    cno = cno + 1
 
def closeExcelSheet(workbook, outputFileName):
  ''' Saves the in-memory WorkBook object into the specified file '''
  workbook.save(outputFileName)
 
def renameOutputFile(outputFileName, fno):
  ''' Renames the output file name by appending the current file number
      to it '''
  dirName, baseName = os.path.split(outputFileName)
  rootName, extName = os.path.splitext(baseName)
  backupFileBaseName = string.join([string.join([rootName, str(fno)], '-'), extName], '')
  backupFileName = os.path.join(dirName, backupFileBaseName)
  try:
    os.rename(outputFileName, backupFileName)
  except OSError:
    print 'Error renaming output file:', outputFileName, 'to', backupFileName, '...aborting'
    sys.exit(-1)
 
def validateOpts(opts):
  ''' Returns option values specified, or the default if none '''
  titlePresent = False
  linesPerFile = -1
  outputFileName = ''
  sepChar = ','
  for option, argval in opts:
    if (option in ('-t', '--title')):
      titlePresent = True
    if (option in ('-l', '--lines')):
      linesPerFile = int(argval)
    if (option in ('-s', '--sep')):
      sepChar = argval
    if (option in ('-o', '--output')):
      outputFileName = argval
    if (option in ('-h', '--help')):
      usage()
  return titlePresent, linesPerFile, sepChar, outputFileName
 
def main():
  ''' Main function '''
  try:
    opts,args = getopt.getopt(sys.argv[1:], 'tl:s:o:h', ['title', 'lines=', 'sep=', 'output=', 'help'])
  except getopt.GetoptError:
    usage()
  if (len(args) < 1): usage() ''' Opens a reference to an Excel WorkBook and Worksheet objects ''' workbook = Workbook() for inputFileName in args: try: inputFile = open(inputFileName, 'r') except IOError: print 'File not found:', inputFileName, '...skipping' continue titlePresent, linesPerFile, sepChar, outputFileName = validateOpts(opts) if (outputFileName == ''): outputFileName = 'output.xls' worksheet = workbook.add_sheet(os.path.basename(inputFileName)) fno = 0 lno = 0 titleCols = [] reader = csv.reader(inputFile, delimiter=sepChar) for line in reader: if (lno == 0 and titlePresent): if (len(titleCols) == 0): titleCols = line writeExcelHeader(worksheet, titleCols) else: writeExcelRow(worksheet, lno, line) lno = lno + 1 if (linesPerFile != -1 and lno >= linesPerFile):
        closeExcelSheet(workbook, outputFileName)
        renameOutputFile(outputFileName, fno)
        fno = fno + 1
        lno = 0
        worksheet = workbook.add_sheet(os.path.basename(inputFileName))
    inputFile.close()
    closeExcelSheet(workbook, outputFileName)
    if (fno > 0):
      renameOutputFile(outputFileName, fno)
 
if __name__ == '__main__':
  main()
```


Comme d’habitude, le script est fournit gracieusement, et surtout « AS-IS with no warranty whatsoever » blablabla ;-) A vos risques et périls quoi!

Par rapport au script initial :

  * Au lieu de mettre un seul fichier en argument de la commande, on peut en spécifier

```
python csv_to_excel.py file1.csv #un fichier, comme avant
python csv_to_excel file1.csv file2.csv file3.csv #plusieurs fichiers, avec un onglet par .csv
python csv_to_excel file*.csv #avec des wildcard, autant d'onglets que de fichiers .csv trouvés
```


  * Il n’y a pas de « nom par défaut » pour le XLS de sortie, car il était récupéré à partir du nom du fichier .csv (ici on en a plusieurs). Si on ne spécifie par le --output, le fichier sera généré en tant que ouput.xls
  * Un fichier non trouvé ne génère plus une erreur bloquante, on passe juste au suivant

**Se l’envoyer par email**

Tant qu’à faire, autant faire les choses jusqu’au bout. Je n’ai pas envie de me connecter sur un serveur ou un partage pour récupérer la dernière version du rapport, je veux la recevoir par email. Pour peut que votre serveur (avec sendmail ou équivalent) soit correctement configuré pour envoyer des emails, la commande **uuencode** permet d’encoder les pièces jointes pour qu’elles puissent être envoyées par la commande mail.

Installation de la commande sous CentOS/RHEL :

```
yum install sharutils
```


On rajoute en crontab un petit shell simple qui lance la commande suivante :

```
uuencode original_report.xls encoded_report.xls | mail -s 'My Report' my@email.com
```
