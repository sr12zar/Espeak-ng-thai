#! /usr/bin/gawk
# *** g2p.awk ***version 0.3.20170725

# Copyright (C) 2017 by Sunthorn Rathmanus
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see: <http://www.gnu.org/licenses/>.
#
# reads records (output) from swath or thwbrk
# expecting fields (syllables) separated by a vertical bar (|) ie.
#    record=f1|f2|f3...\n

# formats syllables in normalised phonemes:='head;vowel;tone;end;'
# translates using phoneme code tabled in "g2p-th2ipa.dat" and utility ipa codes
# output is use-able in "espeak-ng -vTH[+f] ..." as "[[ipa-codes]]".

# to run $> gawk -f g2p.awk -v TH2IPA=th2ipa-table-file [<] infile > outfile

# TH2IPA gawk variable must be set to a th2ipa-table-file
# each th2ipa-table-file record='thai-character pattern'tab(\t)'ipa-code' - no spaces!

BEGIN {
   # set FS to split stream input records into fields
   FS = "|" # ***input must be preprocessed by 'swath' or 'test_thwbrk'***
   k=0 # audit trail count

   # read thai-to-ipa table and build a global ipa array for use later
   if (!TH2IPA) TH2IPA="g2p-th2ipa.dat"
   while ( getline line<TH2IPA ) { split(line, a, "\t"); 	ipa[a[1]]=a[2]; }

   # translation arrays for use in function n2p(number)--> number in words
   for (i=1; i<=12; i++) { cv[substr(".-๐๑๒๓๔๕๖๗๘๙",i,1)]=substr(".-0123456789",i,1) };
   cv[" "]=""; cv[","]=""; # remove blank and comma
   d[0]=""; d[1]="s'i1p"; d[2]="r'qq3j"; d[3]="ph'a0n"; d[4]="m'v1n"; d[5]="s'xx4n"; d[6]="l'aa3n";
   u[0]="s'uu4n"; u[1]="n'v2N"; u[2]="s'@@4N"; u[3]="s'aa4m"; u[4]="s'ii1"; u[5]="h'aa2"; u[6]="h'o1g"; u[7]="dZ'et"; u[8]="ph'xx0t"; u[9]="k'aw2"; # u["-"]="l'q3p"; u["+"]="b'uak";
}

### main ###
{
   print "# " $0
   tx=""; j=0;
   for (i = 1; i <= NF; i++) {
     if ($i !="")  {
	   if (match($i, /[0123456789๐๑๒๓๔๕๖๗๘๙]/)) tx=tx n2p($i) "|"; # a number
           else if (match($i, /[A-Za-z]/)) tx=tx "EN" $i "|"; # flag English text
           else tx=tx g2p($i) "|"; # assume Thai text translate
	   j++
     }
   }
   print tx "_:_||" ;  # ipa (espeak) for end of line and end of sentence
   k+=j
}

END {
   print "# done :", k, "syllables from ", NR, " lines in ", FILENAME
}

### fuctions ###
# ***NOTE*** global variables are used in gawk

function g2p(w) {
#========= translate 1 utterance/syllable/word into ipa phonetic code
   #print "<< g2p-in w=" w
   h=""; v=""; t=""; e=""; dbl=0; dw=""; pause="";  # set global vars
   if (match(w, / $/)) pause="_::|\n" ; # a pause at of syllable/word
   gsub(/ /, "", w); # remove blanks

   factor(w)
   # review parts and fix odd bits -- using global h,v,t,e,dbl
   if (substr(h,1,1)!="*") {
       fixhead()
       if (match(e, /\์/)) karant()
       fixvowel()
       if (e) fixend()
       fixtone()

      #print ">> g2p-exit w=" w "=:" h, v, t, e
       if (dbl) dw="|" ipa[h] "'" ipa[v] t "=" ipa[e]; # repeat for ๆ (dbl)
       return  ipa[h] "'" ipa[v] t "=" ipa[e] dw pause
   } else
   if (substr(h,1,2)=="*-") { # abbreviation say it with a pause
      for (l=3; l<=length(h); l++) { dw=dw ipa[substr(h,l,1) "."] "_:" }
      return dw
   }
}

function factor(w) {
#========== split input into: head h; vowel v; tone t; end e
   if (gsub(/ๆ/,"",w)) dbl=1; # remove ๆ and set double flag
   if (substr(w,1,1)=="เ") { # short เ-vowels
      if (match(w, /(\เ)(.{1,2})(\็)(.*)/, s) ) { #เ-็
            h=s[2]; v="เ-ะ"; e=s[4];
      } else
      if (index(w,"ะ") ) { #short vowels
         if (match(w, /(\เ)(.{1,2})(\ี)([\่\้\๊\๋]?)(\ย\ะ)(.*)/, s) ) { #เ-ียะ
            h=s[2]; v="เ-ียะ"; t=s[4]; e=s[6];
         } else
         if (match(w, /(\เ)(.{1,2})(\ื)([\่\้\๊\๋]?)(\อ\ะ)(.*)/, s) ) { #เ-ือะ
            h=s[2]; v="เ-ือะ"; t=s[4]; e=s[6];
         } else
         if (match(w, /(\เ)(.{1,2})([\่\้\๊\๋]?)(\อ\ะ)(.*)/, s) ) { #เ-อะ
            h=s[2]; v="เ-อะ"; t=s[3]; e=s[5];
         } else
         if (match(w, /(\เ)(.{1,2})([\่\้\๊\๋]?)(\า\ะ)(.*)/, s) ) { #เ-าะ
            h=s[2]; v="เ-าะ"; t=s[3]; e=s[5];
         } else
         if (match(w, /(\เ)(.{1,2})([\่\้\๊\๋]?)(\ะ)(.*)/, s) ) { #เ-ะ
            h=s[2]; v="เ-ะ"; t=s[3]; e=s[5];
         }
      } else { #long เ-vowels
         if (match(w, /(เ)(.{1,2})(\ี)([\่\้\๊\๋]?)(ย)(.*)/, s) ) { #เ-ีย
            h=s[2]; v="เ-ีย"; t=s[4]; e=s[6];
         } else
         if (match(w, /(เ)(.{1,2})(\ื)([\่\้\๊\๋]?)(อ)(.*)/, s) ) { #เ-ือ
            h=s[2]; v="เ-ือ"; t=s[4]; e=s[6];
         } else
         if (match(w, /(เ)([^\่\้\๊\๋]{1,2})([\่\้\๊\๋]?)(อ)(.*)/, s) ) { #เ-อ
            h=s[2]; v="เ-อ"; t=s[3]; e=s[5];
         } else
         if (match(w, /(เ)([^\่\้\๊\๋]{1,2})([\่\้\๊\๋]?)(า)(.*)/, s) ) { #เ-า
            h=s[2]; v="เ-า"; t=s[3]; e=s[5];
         } else
         if (match(w, /(เ)([^\ิ]{1,2})(\ิ)([\่\้\๊\๋]?)(.*)/, s) ) { #เ-ิ = เ-อ
            h=s[2]; v="เ-ิ"; t=s[4]; e=s[5];
         } else
         if (match(w, /(เ)(ว|กษ|ห[ญมนรลย]|.[วลร]*)([\่\้\๊\๋]?)(.*)/, s) ) { #เ-
            h=s[2]; v="เ-"; t=s[3]; e=s[4];
         }
      } #end long เ-vowels
   } else { # non-เ ...other vowels
     if (match(w, /(\แ)([^\่\้\๊\๋]{1,2})([\่\้\๊\๋]?)(\ะ)(.*)/, s) ) { #แ-ะ
        h=s[2]; v="แ-ะ"; t=s[3]; e=s[5];
     } else
     if (match(w, /(\โ)(.{1,2})([\่\้\๊\๋]?)(\ะ)(.*)/, s) ) { #โ-ะ
        h=s[2]; v="โ-ะ"; t=s[3]; e=s[5];
     } else
     if (match(w, /(\ไ)(.{1,2})([\่\้\๊\๋]?)(\ย)(.*)/, s) ) { #ไ-ย
        h=s[2]; v="ไ-"; t=s[3]; e=s[5]; # replace ไ-ย with ไ-
     } else
     if (match(w, /([\เ\แ\ไ\ใ\โ])(ว|กษ|ห[ญมนรลย]|.[วลร]{0,1}*)([\่\้\๊\๋]?)(.*)/, s) ) { #[เ- แ- ไ- ใ- โ-]
        h=s[2]; v=s[1]"-"; t=s[3]; e=s[4];
     } else
     if (match(w, /(.[^\่\้\๊\๋]?{1,2})(\ั)([\่\้\๊\๋]?)(\ว\ะ)(.*)/, s) ) { #-ัวะ
        h=s[1]; v="-ัวะ"; t=s[3]; e=s[5];
     } else
     if (match(w, /(.[^\่\้\๊\๋]?{1,2})(\ั)([\่\้\๊\๋]?)(\ว)(.*)/, s) ) { #-ัว
        h=s[1]; v="-ัว"; t=s[3]; e=s[5];
     } else
     if (match(w, /(.[^\่\้\๊\๋]?{1,2})(\ั)([\่\้\๊\๋]?)(\ม)(.*)/, s) ) { #-ัม
        h=s[1]; v="-ำ"; t=s[3]; e="";
     } else
     if (match(w, /(.[^\่\้\๊\๋]?{1,2})(\ั)([\่\้\๊\๋]?)(\ย)(.*)/, s) ) { #-ัย
        h=s[1]; v="ไ-"; t=s[3]; e="";
     } else
     if (match(w, /(.[^\่\้\๊\๋]?{1,2})(\ื)([\่\้\๊\๋]?)(\อ)(.*)/, s) ) { #-ือ
        h=s[1]; v="-ื"; t=s[3]; e="อ";
     } else
     if (match(w, /(.{1,2})(\ร\ร)([\่\้\๊\๋]?)(.*)/, s) ) { #รร
        h=s[1];  v="-" s[2]; t=s[3]; e=s[4];
     } else
     if (match(w, /(.[^\่\้\๊\๋]?)([\่\้\๊\๋]?)([\อ\ะ\า\ำ\ฤ])(.*)/, s) ) { #[-อ -ะ -า -ำ ฤ]
        h=s[1]; v="-" s[3]; t=s[2]; e=s[4];
     } else
     if (match(w, /(.[^\่\้\๊\๋]?{1,2})([\ิ\ี\ึ\ื\ุ\ู\็\ั])([\่\้\๊\๋]?)(.*)/, s) ) { #[-ิ -ี -ั -ึ -ื -ุ -ู -็ -ั]
        h=s[1]; v="-" s[2]; t=s[3]; e=s[4];
     } else
     if (! match(w, /[\เ\แ\ไ\ใ\โ\ะ\า\ิ\ี\ึ\ื\ุ\ู\ำ\็\ั]/, s) ) { #***no explicit vowel***
        if (gsub(/\./, "", w)) { # a dot -- abbreviation? eg. พ.ศ. or คสช.
            h="*-" w; #print "*- abbrev. ** " h
        } else
        if (match(w, /(.[^\่\้\๊\๋]?)([\่\้\๊\๋]?)(ว)(.{1,})/, s) ) { #** ว  for -ัว with an end
           h=s[1]; v="-ัว"; t=s[2]; e=s[4];
        } else
        if (match(w, /(ขบ|สก|สง|สน|สบ|สม|หม|หย|.[รลวอ]{0,1})([\่\้\๊\๋]?)(.*)/, s) ) { #hidden vowel
           h=s[1]; v="-"; t=s[2]; e=s[3];
        }
     } else { #missed something return as is
        h="*?" w; print "*? missed all ** ", h
     }
   } #end non-เ ...other vowels
}

function karant() {
#========== *** using global vars ***
# Karant - in a word may cover after [the vowel [the tone]] 1-3 chars and -์
# for words from Pali/Sanskrit karant if present is the last char of the word
# from other languages, karant can be used to half/partly silence the char it follows
# a half ะ vowel is needed -- yamakkarn \์ is not on keyboard _็ is similar in function

   n=length(e); #print h, v, t, e " << karant-in"
   if (n > 1) { # karant must follow at least 1 char
      if (match(e, /\์/ ) )  # karant present
         if (RSTART == n) {  # karant is last
           if (match(substr(e,n-1,1), /[\ิ\ุ]/ ) ) # is after sara i or u?
              e=substr(e,1,n-3)  # remove last 3 chars
           else
              e=substr(e,1,n-2)  # remove last 2 chars
           }
        else { #sub(/\์/, " ๎",e); # karant not last - substitute \์ with \ ๎  ???
           e=substr(e,1,RSTART-2) substr(e, RSTART+1); # drop the char and karant
           }
   }
   #else no karant
   #print h, v, t, e " >> karant exit"
}

function fixhead() {
#========== *** using global vars ***
# check for compound head
  #print h, v, t, e " << fixhead-in"
  h1=substr(h,1,1)
  if (h1 != "*") {
     if (h == "ทร" && (match(v, /_[\า\ี]/) ) ) h="ซ"
     else if ((h == "สร") || (match(h1, /[ษศ]/)) ) h="ส"
     else if (h == "ณ") h="น"
     else if (h == "ภ") h="พ"
     else if (h == "ญ") h="ย"
     else if (e == "" ) { # no end
         if ( match(h,/[กคซนตบมรลวห]ว/ ) ) { h=h1; e="ว";} # .ว --> . ว
         else if (match(h,/.[กงดนบมรล]/) )  # 2 consecutive chars
             if (v == "-") { e=substr(h,2,1); h=h1;} # no explicit vowel
         }
     #else if ( match(h, /[กขคขฉช][สษศ]/) ) # กษ->ก ๎ส; ชร ฉล ตล??
     #          { h=h1 " ๎" substr(h,2,1); }
    }
   #print h, v, t, e " >> fixhead-exit"
}

function fixvowel() {
#=========== *** using global vars ***
# rationalize various vowel codings
   #print h, v, t, e " << fixvowel-in"
   if (v == "-" ) { # no explicit vowel
      if ((e == "") || (e == "ร") )  v="-อ"
      else  v="โ-ะ"
      }
   else if ( v == "-รร") {
      if (e == "") { v="-ะ"; e="น" }
      else if (e == "ม") { v="-ำ"; e="" }
      }
   else if (v == "-ฤ") {
      h=h "ร";
      if (substr(e,1,1) == "ก" )  v="เ-อ"
      else v="-ิ"
      }
   else if ((v == "ใ-") || (v == "ไ-") ) { # maybe redundant
      v="ไ-";
      if (e == "ย")  e=""
      }
   else if ((v == "-ั") || (v == "-ะ") ) { # maybe redundant
      if (e == "ย")  { e=""; v="ไ-"}
      else v="-ะ"
      }
   else if (v == "เ-ิ")  v="เ-อ"
   else if (v == "-ว")  v="-ัว"
   # else v as is
   #print h, v, t, e " >> fixvowel-exit"
}

function fixend() {
#========= *** using global vars ***
# transform end consonant(s) into 1 of 8 end-categories (no-end is a category)
# end consonants : (no end), ย, ง, ว, and ม remain as is;
# ด ช ซ ฏ ฉ ฌ ธ ฑ ท ฐ ต ส ศ ษ ฮ -> ด; ญ น ณ ล ร -> น; ก ข ค ฆ -> ก; บ พ ฟ ป -> บ
  #print h, v, t, e " << fixend-in "
  # re-consider the 'end' if not empty
  if (length(e) ) {
     e1=substr(e,1,1);
     if ((e1 == "ว") || (e1 == "อ") ) { # possible vowel
        if (v == "-") { # no vowel but place holder
           v="-" e1; e=substr(e,2); #print v,e
         }
     }
     else if (match(e1, /[งมย]/ ) )  e=e1
     else if (match(e1, /[กขคฆ]/) )  e="ก"
     else if (match(e1, /[บปภพฟ]/) )  e="บ"
     else if (match(e1, /[ญนณรลฬ]/) )  e="น" # นท/นต/... cases?
     else if (match(e1, /[ดจชซฉฌฎฏฐธฑฒทตถสศษฮ]/) )  e="ด"
     # something else as is
   }
  #print h, v, t, e " >> fixend-exit"
}

function fixtone() {
#========== *** using global vars ***
#*** terms: none: <no end>; dead end: ก ด บ; live end: น ง ม ย ว
#*** Rules:
#- R1: low tone head + short vowel + none/dead end --> high tone -๋
#- R2: low tone head + long vowel + any end --> low tone -่ ??? level
#- R3: high tone head + short vowel + none --> low tone -่
#- R4: high tone head + any vowel + dead-end --> low tone -๋
#- R5: high tone + -่ --> -่ ; + -้ --> -้ ; + -๊ --> -๊
#- R6: low tone + -่ --> -้ ; + -้ --> -๊ ; prefixed with ห, อ, a high tone char --> -๋
#- R7: others as they are transcribed.
# change t to number (t=="") { t=0 } else { t=index("-่-้-๊-๋", s[4])/2 } ??
   #print h, v, t, e, " << fixtone-in"
   tone="0" # set tone to 'level'
   h1=substr(h,1,1) # 1st char of head
   v9=substr(v,length(v)) # last char of vowel *** can be a "-" as in โ- เ- ...

   if ( match(h1, /[คฅฆงชซฌญฑฒณทธนพฟภมยรลวฬฮ]/) ) { # low tone head
      if ( match(v9, /[\ะ\ิ\ึ\ุ]/) && (e == "" || match(e, /[กดบ]/)) ) { # R1
         tone="4"; # set high and check R5
         if        (t == "่") tone="1"
         else if (t == "้") tone="2"
         else if (t == "๊") tone="3"
         }
      else { # R2 - long vowel
         tone="0"; # set low and check R6 ??? tone=1
         if        (t == "่") tone="2"
         else if (t == "้") tone="3"
         }
      }
   else if (match(h1, /[ขฃฉฐถผฝศษสห]/) ) { # high tone head
      tone="4" # set tone high first
      if ( (match(v9, /[\ะ\ิ\ึ\ุ]/) && (e == "")) || (match(e, /[กดบ]/)) ) { # R3 or R4
         tone="1"; # set low and check R6
         if        (t == "่") tone="2"
         else if (t == "้") tone="3"
         }
      else if ( match(h,/(สก|สค|สต)/) ) tone="0" # foreign words ???
      else {
        # set high and check R5
        if        (t == "่") tone="1"
        else if (t == "้") tone="2"
        else if (t == "๊") tone="3"
        }
      }
   else { # as is by R7 -- norminal tone
      if         (t == "") tone="0"
      else if  (t == "่") tone="1"
      else if  (t == "้") tone="2"
      else if  (t == "๊") tone="3"
      else if  (t == "๋") tone="4"
   }
   t=tone
  #print h, v, t, e " >> fixtone exit"
}

function n2p(w, i,ix) { # note local i and ix to avoid corrupting other i
#===========# convert a simple number to words (in ipa)
   #print  "<< n2p in  w=" w
   n=""; # remove blank and convert TH number to arabic
   if (match(w,/[๐๑๒๓๔๕๖๗๘๙]/))
      for (i=1; i<=length(w); i++) { n=n cv[substr(w,i,1)] }
   else n=gensub(/[, ]/, "", "g", w)
   #print "n2p(" n ")"
   w=n; tx=""; split(w, p, "."); # split decimal number
   if (substr(p[1],1,1)=="-") { tx="l'q3p"; p[1]=substr(p[1],2); }
   else if (substr(p[1],1,1)=="+") { tx="b'uak"; p[1]=substr(p[1],2); }
   lp1=length(p[1]); lp2=length(p[2])
   if (lp1==0) p[1]="0"

   for (i=1; i <= lp1; i++) {
       p1i=substr(p[1],i,1); ix=(lp1-i)%6; # print "***ix=" ix
       if (p1i=="1" && ix==0 && substr(p[1],i-1,1)!="0") tx=tx "'e0t_|"
       else if (p1i=="2" && ix==1) tx=tx "j'ii2|" d[1] "|" # 20
       else if (p1i=="1" && ix==1) tx=tx d[1] "|" # 10
       else if (p1i != "0") { tx=tx u[substr(p[1],i,1)]; if (lp1-i) tx=tx "|" d[(lp1-i)%6] "|"; }
       if ((lp1-i)>5 && ix==0) tx=tx d[6] "|" # million
       if ((lp1-i)>11 && ix==0) tx=tx d[6] "|" # billion in Thai million-million
       if ((lp1-i)>17 && ix==0) tx=tx d[6] "|" # trillion **limit of implementation
   }
   if (lp2) {
      tx=tx "dZ'u1t|";   # read "."
      for (i=1; i <= lp2; i++) { tx=tx u[substr(p[2],i,1)] "|" }
   }
   #print " >> n2p exit w=" w " tx=" tx
   return tx
}
###end-of-file###
