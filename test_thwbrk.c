/* Test driver for thwbrk
	This version is modified by Sunthorn Rathmanus 24 Jul 2017
	- to increase MAXLINELENGTH (for input string) from 1000 to 8190
	- to allow option i<input Thai text in UTF-8> when run on a Linux machine
 NB. Original test string (we can't read) is in obsolete TIS 41/Windows utf16 coding.
*/

#define MAXLINELENGTH 8190

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <thai/thbrk.h>
#include <thai/thwchar.h>
#include <thai/thwbrk.h>

#include <wchar.h>
#include <locale.h>

int main (int argc, char* argv[])
{
  thchar_t str[MAXLINELENGTH];
  thwchar_t ustr[MAXLINELENGTH], uout[MAXLINELENGTH], unicodeCutCode[6];

  int pos[MAXLINELENGTH];
  int outputLength, unicodeCutCodeLength;
  int numCut, i;
  ThBrk *brk;
	
  brk = th_brk_new (NULL); // new object and tdict available?
  if (!brk) {
    printf ("Unable to create word breaker!\n");
    exit (-1);
  }
 
// check arhument and set stdout stream orientation to wchar by printf
  setlocale(LC_ALL, "");
  if (argc >= 2) {
     if (0 == strcmp (argv[1], "-i")) {
        if (argc == 2) {
           //while (!feof (stdin)) {
              //printf ("> ");
              //if (!fgets ((char *) str, MAXLINELENGTH-1, stdin)) {
	            fgets ((char *) str, MAXLINELENGTH-1, stdin);
                str[strcspn(str, "\n")] = 0; //strtok(str, "\n");
                mbstowcs (ustr, str, MAXLINELENGTH); 
                //printf ("Typed : %s\n", str);
              //}  
           //}
        } else {
           if (argc >= 3) {
	      strcpy ((char *) str, argv[2]);
	      mbstowcs (ustr, str, MAXLINELENGTH);
              //printf ("Given : %s\n", str);
           } 
        }
    }
  } else {
     // TIS 41 char string is defaulted ??? Is this Windows utf16 ??	
     strcpy (str, "สวัสดีครับ กอ.รมน. นี่เป็นการทดสอบตัวเอง");
     th_tis2uni_line (str, ustr, MAXLINELENGTH);
	// instead of mbstowcs (ustr, str, MAXLINELENGTH);
     printf ("Preset : %s\n", str);
  }
  
  //printf ("%ls  Length : %d\n", ustr, wcslen(ustr));

  //printf ("Calling th_brk_wc_find_breaks()...\n");
  numCut = th_brk_wc_find_breaks (brk, ustr, pos, MAXLINELENGTH);

/* 
  //printf ("Total %d cut points.", numCut);
  if (numCut > 0) {
     printf ("Cut points list: %d", pos[0]);
     for (i = 1; i < numCut; i++) {
       printf (", %d", pos[i]);
     } 
  }
  printf ("\n");
*/

  // put '|' into unicodeCutCode -- a round-about way
  unicodeCutCodeLength = th_tis2uni_line ((const thchar_t *) "|",
                                                                  (thwchar_t*) unicodeCutCode, 6);

  //printf ("Calling th_brk_wc_insert_breaks()..maxLlen %d.\n", MAXLINELENGTH);
  outputLength = th_brk_wc_insert_breaks (brk, ustr, (thwchar_t*) uout, 
                                                                  MAXLINELENGTH, unicodeCutCode);
  //printf ("OutputLength : %d  wcslen : %d\n", outputLength, wcslen(uout)); 
  // output after-broken-up string 
  printf ("%ls\n", uout); 
	
  th_brk_delete (brk);

  return 0;
}
