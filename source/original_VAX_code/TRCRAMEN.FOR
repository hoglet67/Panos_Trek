      SUBROUTINE CRAMEN(II) 
	ENTRY CRAMENA(II)
	INCLUDE 'TREKCOM/NOLIST'
	LOGICAL*1 II
      IF(II .EQ. IHR) GO TO 10
      IF(II .EQ. IHK) GO TO 20
      IF(II .EQ. IHC) GO TO 30
      IF(II .EQ. IHS) GO TO 40
      IF(II .EQ. IHSTAR) GO TO 50 
      IF(II .EQ. IHP) GO TO 60
      IF(II .EQ. IHB) GO TO 70
      IF(II .EQ. '@') GO TO 80
      IF(II .EQ. IHT) GO TO 85
      IF(II-2) 90,100,110 
 10   CALL CRAM(7HROMULAN) 
	RETURN
 20   CALL CRAM(7HKLINGON) 
	RETURN
 30   CALL CRAM(9HCOMMANDER) 
	RETURN
 40   CALL CRAM(15HSUPER-COMMANDER)
	RETURN
 50   CALL CRAM(4HSTAR)
	RETURN
 60   CALL CRAM(6HPLANET)
	RETURN
 70   CALL CRAM(8HSTARBASE)
	RETURN
 80   CALL CRAM(10HBLACK HOLE) 
	RETURN
85    CALL CRAM(7HTHOLIAN)           
	RETURN
 90   CALL CRAM(1HM) 
	RETURN
 100  CALL CRAM(1HN) 
	RETURN
 110  CALL CRAM(1HO) 
	RETURN
      END 
