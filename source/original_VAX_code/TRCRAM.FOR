      SUBROUTINE CRAM(M)
	COMMON/PRLUN/LUN
      BYTE M(1)
C--------<M> IS AN ARRAY CONTAINING CHARACTERS LJZF.  BYTES ARE PUT
C--------INTO THE OUTPUT BUFFER UP TO THE FIRST 00B BYTE.
      BYTE LINE(120)
      DATA LINE/120*0/,ICH/1/
	K=80
	GO TO 11
C*
	ENTRY CRAMS(M,IK)
C*
	K=IK
11    IDUMP=0
5     ICHX=0
C--------GET THE NEXT CHARACTER OF <M>
10	ICHX=ICHX+1
	IF (ICHX.GT.K) GOTO 21
	KHAR=M(ICHX)
C--------PUT IT IN BUFFER
      IF(KHAR .EQ. 0) GO TO 21
	LINE(ICH)=KHAR
      ICH=ICH+1
	IF(ICH.GT.120) GOTO 25 
	IF((ICH.GT.72).AND.(LUN.EQ.1)) GOTO 25
      GO TO 10
C*
      ENTRY CRENDNO 
C--------DUMP BUFFER AND SUPPRESS LINE FEED
	CALL PROMPT (LINE,ICH)
	GOTO 27
C*
      ENTRY CRAMDMP (M)
C--------INSERT FINAL ENTRY AND DUMP BUFFER
	K=80
	GO TO 22
C*
	ENTRY CRMDPS(M,IK)
	K=IK
22    IDUMP=1
      GO TO 5
21	IF(IDUMP.EQ. 0) RETURN 
      ENTRY CREND
C--------DUMP BUFFER AND GO TO NEW LINE 
 25   CALL PROUT(LINE,ICH)
27      DO 30 L=1,ICH 
 30   LINE(L)=0
      ICH=1
      RETURN
      END 
      SUBROUTINE CRAMF(XX,W,D)
	BYTE CF(10),CS(10)
	INTEGER*4 I
      INTEGER W,D
      NEG=0
	DO 5 N=1,10
5	CF(N)=0
      X=XX
      IF(X .GE. 0) GO TO 10
      X=-XX
      NEG=1
 10   N=0 
      IF(D .EQ. 0) GO TO 30
C--------CONVERT FRACTIONAL PART TO ASCII
      I=X*10**D+.5
      DO 20 N=1,D
      J=MOD(I,10)
	CF(N)=1H0+J
 20   I=I/10
C--------INSERT DECIMAL POINT 
      N=D+1
	CF(N)=1H.
C--------CONVERT INTEGRAL PART TO ASCII
 30   J=MOD(I,10)
      N=N+1
	CF(N)=1H0+J
      I=I/10
      IF(I .NE. 0) GO TO 30
C--------INSERT MINUS SIGN IF NEEDED
      IF(NEG .EQ. 0) GO TO 40 
      N=N+1
	CF(N)=1H-
C--------PAD WITH BLANKS TO TOTAL OF <W> CHARACTERS
 40   IF(N .GE. W .OR. N .GE. 9) GO TO 43
      N=N+1
	CF(N)=1H 
      GO TO 40
43	DO 45 I=1,N
45	CS(I)=CF(N-I+1)
	CS(N+1)=0
 50   CALL CRAM(CS) 
      RETURN
      END 
      SUBROUTINE CRAMI(II,W)
	BYTE CI(10),CS(10)
      INTEGER W
      I=II
      NEG=0
      IF(I .GE. 0) GO TO 10
      I=-II
      NEG=1
C--------CONVERT THE NUMBER ITSELF TO ASCII
10	DO 15 N=1,10
15	CI(N)=0
      N=0 
 20   J=MOD(I,10)
      N=N+1
	CI(N)=1H0+J
      I=I/10
      IF(I .NE. 0) GO TO 20
C--------INSERT MINUS SIGN IF NEEDED
 30   IF(NEG .EQ. 0) GO TO 40 
      N=N+1
	CI(N)=1H-
C--------PAD WITH BLANKS TO TOTAL OF <W> CHARACTERS
 40   IF(N .GE. W .OR. N .GE. 9) GO TO 43
      N=N+1
	CI(N)=1H 
      GO TO 40
43	DO 45 I=1,N
45	CS(I)=CI(N-I+1)
	CS(N+1)=0
	CALL CRAM(CS) 
      RETURN
      END 
