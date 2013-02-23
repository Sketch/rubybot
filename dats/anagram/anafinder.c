#include <stdio.h>

int main(int argc,char *argv[]) {
  FILE *fin;
  char buff[0x100];
  char word[0x100];
  char extry[0x100];
  int  yes[0x100];
  int  len,len_min,len_max;

  if (argc != 4) {
    printf( "Usage: %s <file> <pattern> <length>\n", argv[0] );
    return 1;
  }

  if ((fin = fopen( argv[1], "r" )) == NULL) {
    printf( "No such file\n" );
    return 1;
  }

  snprintf(word,0x100,"%s",argv[2]);

  
  len_min = atoi(argv[3]);
  
  len_max=strlen(word);

  for (len=0;len<len_max;len++)
    word[len] = tolower(word[len]);

  while (fgets(buff,0x100,fin) != NULL) {
    int i;
    int j;
    int e;
    int unfound;
    int goodword;

    for (i=0;i<len_max;i++)
      yes[i] = 1;

    len = strlen(buff);

    for (i=0;i<len;i++)
      buff[i] = tolower(buff[i]);

    if (buff[len-1] == '\n')
	    len--;
    buff[len] = '\0';

    if (len < len_min || len > len_max)
      continue;

    e=0;
    goodword=1;
    for (i=0;(i<len)&&goodword;i++) {

      // printf( "evaluating %s. len: %d i: %d\n", buff, len, i );
      unfound=1;
      for (j=0;(j<len_max)&&unfound;j++) {
	if (yes[j] && (word[j] == buff[i])) {
	  unfound=0;
	  yes[j] = 0;
	  // printf( "match: (%c == %c). i=%d j=%d\n", word[j], buff[i], i, j );
	}
      }
      if (unfound) {
	for (j=0;j<len_max&&unfound;j++) {
	  if (yes[j] && (word[j] == '?')) {
	    extry[e++]=buff[i];
	    unfound=0;
	    yes[j]=0;
	  }
	}
      }
      if (unfound == 1)
	goodword=0;
    }
      extry[e]=0;
    if (goodword)
      printf( "%s\n", buff );
  }
  return 0;
}
