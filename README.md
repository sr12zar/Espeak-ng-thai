# ESPEAK-NG-THAI

A Thai language toolset for word segmentation and translation into an ipa code for feeding into Espeak-ng.

For the Thai version of this document, see อ่านก่อน.md.

## Introduction

'Espeak-ng-thai' is a text-to-speech toolset for Thai laguage. It is developed to investigate issues within Thai tts and to facilitate development Thai speech recognition (sr). This tool is a working model and still in development. It is built using publicly available Linux free and open-source software packages (as components) and simple pattern-matching rule-based algorithms. It is released in hope that it may be useful in encouraging further development of Thai tts and Thai sr technologies for interactions between man and machine in the age of robots - the next decade or so.

Design Espeak-ng-thai follows a simple approach with a grapheme-to-phoneme (G2P) step, followed by a phoneme synthesizer step.

The G2P step still remains a challenge in Thai tts due to lack of word delimiters in Thai writing and many adopted conventions and words from other languages. Many strategies and methods have been developed and reported. All G2P conversions achieved high levels of success but refinements are still needed. This G2P (Espeak-ng-thai) is based on pattern matching of utterance and rule-based conversion of a common and logical sound unit (that Thais are taught to read at school for examples ก -ะ, ก -า, ก -า ง ้, ส เ-ือ ้, and so on).

In this Espeak-ng-thai package, strings of Thai graphemes (text) are segmented into basic units (called syllables or utterances) using a word-dictionary-based program such as 'swath' or '(libthai) thbrk'. An utterable dictionary is built to be used with these programs to segment Thai text into syllables rather than words.

Once segmented into syllables, each syllable is pattern matched in very much the same fashion as a Thai would do when s/he tries to read. Syllables are formatted as patterns (described by the construct) and then translated into phonemes.

The synthesizer step is a simpler part of tts. There are many different and freely available speech synthesizers (espeak, festival, mbrola, pico, svox and so on). Most accept 'phoneme strings' and generate wave files which can be played to produce speech.

It is unfortunate that many different 'phonetic codes' are used by these synthesizers.

In short Thai text is segmented into syllables then translated into a phoneme string for input into a synthesizer to generate an audio wave of the text.

**Note.** A sound unit is symbolized as {head char[vowel][end char][intonation]} where head char denotes leading consonant (absence of head char as in English 'an' or 'in' is represented by a letter 'อ' in Thai); end char is tail/'final' consonant; where terms in [] may not be present or omitted.

Thai vowels can consist up 4 letters and its components of vowel may be placed before, over, under, or after head char, or omitted in writing; word intonation depends on the intonation mark (usually over the head consonant letter), 'pitch' of head char (high, middle or low), short or long vowel, and the type of end char (dead or live). So the tone of a word can be different from the actual (intonation) mark used.

## Construction

Espeak-ng-thai is developed and tested on a computer running Ubuntu 16.04LTS and later Linux Mint 20.1. The work described below may not suit other computers.

A number of publicly available free and opensource software and data packages are used used in this toolset. ==Thanks to their contribution (to the world) for making the experiments possible within our means.==

### Utterdict

The syllable dictionary (in ./th-utterdict/) is a trie structure built with -libdatrie- using searchword data in the Royal Society (Thai-Thai) dictionary edition of 2542 BE.

Much edition has been done using 'trietool' in libdatrie a dependency of libthai. Try in a terminal:
```
(pathto)/libdatrie/tools/tritool --help
```
### Segmentation

Either 'swath' and (libthai) 'test-thwbrk' can be used to break Thai text into syllables. But their associated and defaulted word-based dictionary must be replaced by the utterable dictionary (supplied in subdirectory /utterdict in this package).

Both 'swath', 'libthai' (and a libthai dependency 'libdatrie') packages can be obtained from https://github.com/tlwg or https://linux.thai.net/projects/.

If 'swath' is to be used to segment text into syllables, the syllable dictionary (supplied in ../utterdict) must be specified instead of its own ..data/swathdic.tri. eg.
```
echo "สวัสดีค่ะ" | swath -u u,u -d (path-to)/th-utterdict/thbrk.tri
would output
สวัส|ดี|ค่ะ
```
If 'thwbrk' is used, then the program test_thwbrk.c (.../libthai.../tests/) is to be modified (as supplied, see its source code) and compiled with others using the usual Linux system 'make' (./configure, make, and 'make test') to build test_thwbrk for use in breaking Thai phrases into syllables. The syllable dictionary (supplied in ../th-utterdict/ ) is to be used in place of libthai/data/thbrk.tri by specifying LIBTHAI_DICTDIR eg.
```
LIBTHAI_DICTDIR=(path-to)/th-utterdict (path-to-modified)/tests/test_thwbrk -i "สวัสดีครับ"
would produce
สวัส|ดี|ครับ
```
*Note.* libthai needs just 'make' to compile but not 'make install' (to install for systemwide use. 'espeak-th' bash script runs it from the libthai source directory).

### Espeak-ng

Espeak-ng package is obtained from https://github.com/espeak-ng/. Thai language specifics are to be added to various files in the package to add and build Thai language into Espeak-ng.

_At as Jan 2021, Thai language is added to espeak-ng master package. However, this addition makes Thai language a subset Tai Yai (or Shan) language when Thai is a superset. (Thai has more consonants and more vowels. Thai also has strong emphases on 'tones'). Loatian and Thai dialects may be implemented based on ph_Thai but not Ph_shan._

## Espeak-ng-thai Supplied Source:

Please refer to espeak-ng's ../docs/add_languages.md before making these changes and Espeak-ng's README.md before building Espeak-ng with Thai language. You may like to install some dependency pakages eg. by issuing on a terminal
- ./autogen.sh
- ./configure 

### Modifying Espeak-ng

- To insert into _Makefile.am_ file (for 'make') as follow

section _phsource/phonemes.stamp:_ **phsource/ph_thai** \

section _dictionaries:_ **espeak-ng-data/th_dict** \

and add _th:_ section with
```
th: espeak-ng-data/th_dict espeak-ng-data/th_dict: dictsource/th_list dictsource/th_rules dictsource/th_extra 
```
- To go into ../espeak-ng-data/lang/
1.  ./tai
2.  ../th 

**This is already done in the current package of espeak-ng.**

- To copy into ../dictsource/
```
{ - th_rules
  - th_list
  - th_extra
}
```
*Note*. At present both th_list and th_extra are just empty files. The original th_rules file if exists must be replaced with the one supplied.

- To copy into ../phsource/
```
{ ph_thai }
```
- To edit and append to content of ../phsource/phonemes file
```
phonemetable th base1
include ph_thai 
```
These files and changes must be applied to espeak-ng source before the usual build process (eg. ./autogen.sh, ./configure, make, make test, ...). If there are any errors in the build process, do a 'make clean', amend the errors and restart the build process again.

*Note.* If there are further change to ph_thai then 'make th' may be used to recompiled ph_thai instead of 'make'. See documentation in espeak-ng.

### Gawk

The Gnu awk (gawk) script, *g2p.awk* is written and used to pattern match and translate Thai sylables into phonemes.

See https://www.gnu.org/s/gawk/manual/html_node/Quick-Installation.html for 'gawk'  installation details for your Linux distribution.

### g2p.awk

g2p.awk is a gawk script for converting syllable-segmented Thai text graphemes into graphemes of a (ipa) phonetic code.

### g2p-th2ipa.dat

The file g2p-th2ipa.dat contains a grapheme-to-phoneme translation table. Different tables may be used to translate to different phoneme codes.

**Note.** Espeak-ng is used in this project as the synthesizer, so the translation is into espeak's phonetic code.

### espeak-th

The bash script 'espeak-th' is provided for testing both g2p and synthesizer steps.
(Note. espeak-th accepts options: -i "thai text" and -f file-containing-thai-text)
eg.
```
$ espeak-th -i"สวัสดีค่ะ" 
would respond with a voice and details of its analysis
# สวัส|ดี|ค่ะ s,aw'a1=d|d'ii0=|kh'a1=|:||
# done : 3 syllables from 1 lines in -
```
or
```
$ (path-to)/speak-th -f file-containing-thai-text 
```
Several .tmp files are created and left for debugging: espeak-th-inf.tmp, espeak-th-auf.au, espeak-th-brk.tmp, and espeak-th-ipa.tmp.

For other options please see the bash script.

## More To Do

- Improve voicing by modifying ph_thai or perhaps using MBROLA or PRATT voice files
- Look for ways to integrate 'g2p' of thai text to espeak-ng
- Improve utterdict and include more 'modern Thai'

## License

'espeak-th' is copyrighted by its authors and licensed under terms of the GNU General Public License - see file COPYING for details.

'espeak-ng', 'libthai', 'libdatrie', 'GNU awk' 'swath' are also copyrighted by its authors and licensed under terms of the GNU General Public License - see file COPYING for details.

## Summary

'Espeak-ng-thai' package is developed as an example of pattern-matching-based Thai tts model. It uses or modify publicly available packages to build various components of this tts system. The package should run on any Linux distribution but is tested only on Ubuntu 16.04LTS and Linux Mint 20.1.

## Epilogue

I hope to see further Thai tts development on different dialects of Thai language. Laotian and Pali tts may also be developed by from this package.

I will try to answer any question but I am retired and live in a rural -poor telecomunication- area which means 'do not expect quick reply'. So, be patient and 'enjoy' Espeak-ng-thai as an experiment.

sr12zar@gmail.com
