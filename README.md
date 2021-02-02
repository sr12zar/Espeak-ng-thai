# Espeak-ng-thai
A Thai language toolset for word segmentation and translation into an ipa code for feeding into Espeak-ng.


Introduction

'Espeak-ng-thai' is a text-to-speech toolset for Thai laguage. It is developed to investigate issues within Thai tts and to facilitate development Thai speech recognition (sr). This tool is a working model and still in development. It is built using publicly available Linux distribution packages (as components) and simple pattern-matching rule-based algorithms. It is released in hope that it may be useful in encouraging further development of Thai tts and Thai sr technologies for interactions between man and machine in the age of robots - the next decade or so.

Design
Espeak-ng-thai follows a simple approach with a grapheme-to-phoneme (G2P) step, followed by a phoneme synthesizer step.

The G2P step still remains a challenge in Thai tts due to lack of word delimiters in Thai writing and many adopted conventions and words from other languages. Many strategies and methods have been developed and reported. All G2P conversions achieved high levels of success but refinements are still needed. This G2P (Espeak-ng-thai) is based on pattern matching of utterance and rule-based conversion of a common and logical sound unit (that Thais are taught to read at school for examples ก -ะ, ก -า,  ก -า ง  ้, ส เ-ือ  ้, and so on).

Note.
A sound unit is symbolized as {<head char>[<vowel>][<end char>][<intonation>]} where
<head char> denotes leading consonant; <end char> tail consonant;...
Terms in [] may not be present or omitted; components of <vowel> may be placed before, over, under, or after <head char>, or omitted in writing; <intonation> depends on tone of <head char> (high, middle or low), short or long vowel, and type of <end char> (dead or live). So <intonation> can be different from actual (Thai intonation) mark used.

In this Espeak-ng-thai package, strings of Thai graphemes (text) are segmented into basic units (called syllables or utterances) using a word-dictionary-based program such as 'swath' or '(libthai) thbrk'. An utterable dictionary is built to be used with these programs to segment  Thai text into syllables rather than words.

Once segmented into syllables, each syllable is pattern matched in very much the same fashion as a Thai would do when s/he tries to read. Syllables are formatted as patterns (described by the construct) and then translated into phonemes.

The synthesizer step is a simple part of tts. There are many different and freely available speech synthesizers (espeak, festival, mbrola, pico, svox and so on). Most accept 'phoneme strings' and generate wave files which can be played to produce speech.

It is unfortunate that many different 'phonetic codes' are used by these synthesizers.

So Thai text is segmented into syllables then pattern matched and translated into a phoneme string for input into a synthesizer to generate an audio wave of the text.

Construction

Espeak-ng-thai is developed and tested on an Intel I5 4GB RAM computer with Ubuntu 16.04LTS.
The work described below may not suit other computers.

Either 'swath' and (LibThai) 'thwbrk' can be used to break Thai text into syllables. But their associated and defaulted word-based dictionary must be replaced by the utterable dictionary (supplied in subdirectory /utterdict in this package).

'swath', 'libthai' (and a libthai dependency 'libdatrie') packages can be obtained from https://github.com/tlwg or https://linux.thai.net/projects/.

If 'swath' is to be used to segment text into syllables, the syllable dictionary (supplied in ../utterdict) must be specified instead of its own ..data/swathdic.tri. eg.

	echo "สวัสดีค่ะ" | swath -u u,u -d (path-to)/th-utterdict/thbrk.tri

eg. echo "สวัสดีค่ะ" | swath -u u,u -d th-utterdict/thbrk.tri
>>  สวัส|ดี|ค่ะ

If 'thwbrk' is used, then the program test_thwbrk.c (.../libthai.../tests/) is to be modified (as supplied, see its source code) and compiled with others using the usual Linux system 'make' (./configure, make, and 'make test') to build test_thwbrk for use in breaking Thai phrases into syllables. The syllable dictionary (supplied in ../th-utterdict/ ) is to be used in place of libthai/data/thbrk.tri by specifying LIBTHAI_DICTDIR eg.

	LIBTHAI_DICTDIR=(path-to)/th-utterdict (path-to-modified)/test_thwbrk -i "สวัสดีครับ"

eg. LIBTHAI_DICTDIR=./th-utterdict ./libthai-0.1.27/tests/test_thwbrk -i "สวัสดีครับ"
>>  สวัส|ดี|ครับ

Note that libthai needs just 'make' to compile but not 'make install' (to install for systemwide use. 'espeak-th' bash script runs it from the libthai source directory).

The Gnu awk (gawk) script, g2p.awk is written and used to pattern match and translate  Thai sylables into phonemes. (In this package espeak-ng is used as the synthesizer, so the translation is into espeak's phonetic code). See https://www.gnu.org/s/gawk/manual/html_node/Quick-Installation.html for installation details for your Linux distribution.

Espeak-ng-thai Supplied Source:

The file g2p-th2ipa.dat contains a grapheme-to-phoneme translation table. Different tables may be used to translate to different phoneme codes.

Note. Espeak-ng is used in this example.
Espeak-ng package is obtained from https://github.com/espeak-ng/.
Thai language specifics are added to various files in the package to add and build Thai language into Espeak-ng.

***Please refer to espeak-ng's ../docs/add_languages.md before making these changes and Espeak-ng's README.md before building Espeak-ng with Thai language. You may like to install some dependency pakages (eg. by issuing on a terminal 'sudo apt-get install libsonic-dev').

To insert into "Makefile.am" file (for 'make') as follow

section  "phsource/phonemes.stamp:"
    phsource/ph_thai \

section "dictionaries: "
    espeak-ng-data/th_dict \

and add "th:" section with
    th: espeak-ng-data/th_dict
    espeak-ng-data/th_dict: dictsource/th_list dictsource/th_rules
    dictsource/th_extra

To go into ../espeak-ng-data/lang/
    ./tai
    ../th

To go into ../dictsource/
    th_rules
    th_list
    th_extra

To go into ../phsource/
    ph_thai

and append to ../phsource/phonemes file
    phonemetable th base1
	include ph_thai

These files and changes must be applied to espeak-ng source before the usual build process (eg. ./configure, make, make test, ...). If there are any errors in the build process, do a 'make clean', amend the errors and restart the build process again.

Note that if there are further change to ph_thai then 'make th' must be used to recompiled ph_thai. See documentation in espeak-ng.


g2p.awk is a gawk script for converting syllable-segmented Thai text graphemes into graphemes of a (ipa) phonetic code.

The bash script 'espeak-th' is provided to do both G2p and synthesizer steps for testing.

espeak-th accepts options: -i and -f

	$ (path-to)/espeak-th -i<Thai text>
eg. $ espeak-th -i"สวัสดีค่ะ"
would respond with a voice and details of tts analysis
    # สวัส|ดี|ค่ะ
    s,aw'a1=d|d'ii0=|kh'a1=|_:_||
    # done : 3 syllables from 1 lines in -

or
	$ (path-to)/speak-th -f<Thai text file>

For other options please see the bash script.

License

'espeak-th' is copyrighted by its authors and licensed under terms of the GNU Lesser Public License (LGPL) - see file COPYING for details.

'espeak-ng', 'libThai', 'libdatrie', GNU awk' are also copyrighted by its authors and licensed under terms of the GNU Lesser Public License (LGPL).

Summary

'Espeak-ng-thai' package is developed as an example of pattern-matching-based Thai tts model. It uses publicly available packages to build various components of this tts system. The package should run on any Linux distribution but is tested only Ubuntu 16.04LTS.


Epilogue

I hope to see further Thai tts development on different dialects of Thai language. Laotian tts may also be developed by from this package.

I will try to answer any question but I live in a rural -poor telecomunication- area means 'do not expect quick reply'. So, be patient and 'enjoy' Espeak-ng-thai as an experiment.
