      SUBROUTINE DREPORT
	INCLUDE 'TREKCOM/NOLIST'
      INTEGER HDEVICE(40),NAME(2) 
      JDAM=0
      DO 20 L=1,NDEVICE 
      IF(DAMAGE(L) .LE. 0) GO TO 20 
      IF(JDAM .NE. 0) GO TO 10
      CALL SKIP(1)
      CALL PROUT(35HDEVICE               -REPAIR TIMES-,35)
      CALL PROUT(37H                   IN FLIGHT   DOCKED,37)
      JDAM=1
10    CALL CRAM(2H  ) 
      CALL CRAMS(DEVICE(2*L-1,1),16) 
      IF(L.NE.14) CALL CRAMF(DAMAGE(L)+0.005,5,2) 
      IF(L.EQ.14) CALL CRAM(5H  -  )  
      CALL CRAMF(DOCKFAC*DAMAGE(L)+0.005,10,2)
      CALL CREND
 20   CONTINUE
      IF(JDAM .EQ. 0) CALL PROUT(23HALL DEVICES FUNCTIONAL.,23)
      RETURN
      END 
