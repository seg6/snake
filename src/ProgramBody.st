IF bLArrow AND (sSnake.dir <> wSnakeDirRight) THEN sSnake.dir := wSnakeDirLeft;  END_IF;
IF bRArrow AND (sSnake.dir <> wSnakeDirLeft)  THEN sSnake.dir := wSnakeDirRight; END_IF;
IF bUArrow AND (sSnake.dir <> wSnakeDirDown)  THEN sSnake.dir := wSnakeDirUp;    END_IF;
IF bDArrow AND (sSnake.dir <> wSnakeDirUp)    THEN sSnake.dir := wSnakeDirDown;  END_IF;
	
IF SM402 THEN
	STRINGMOV(TRUE, 'SEG6', D300);
END_IF;

CASE wState OF
	wMenuState:
		bMenuScreen := TRUE;

		IF bStart THEN
			bMenuScreen := FALSE;
			wState := wInitState;
		END_IF;
			
	wGameOverState:
		bGameOver := TRUE; // switches the active screen to "2 GameOver", trigger: on Rise
			
		IF bStart THEN
			bGameOver := FALSE;
			wState := wMenuState;
		END_IF;

	wInitState:
		WIDTH  := 14;
		HEIGHT := 14;
		uScore := 0;

		sSnake.dir      := wSnakeDirLeft;
		sSnake.length   := 2;
		sSnake.shead.pX := 6;
		sSnake.shead.pY := 6;
		
		sSnake.body[0].pY := sSnake.shead.pY; sSnake.body[0].pX := sSnake.shead.pX + 1;
		sSnake.body[1].pY := sSnake.shead.pY; sSnake.body[1].pX := sSnake.shead.pX + 2;

		RND(TRUE, sFood.pX);
		RND(TRUE, sFood.pY);

		sFood.pX := sFood.pX MOD WIDTH;
		sFood.pY := sFood.pY MOD HEIGHT;
		sFood.color := RED;
		
		tTimer := T#100ms;
		wState := wEventState;

	wEventState: (* event handler *)
		IF bReset THEN wState := wInitState; END_IF;
		IF wState = wEventState THEN wState := wUpdateState; END_IF;

	wUpdateState:
		FbIsOnSnake(sSnake.shead.pX, sSnake.shead.pY, bBool);
		IF bBool = TRUE THEN wState := wGameOverState; END_IF;

		IF sSnake.length > 0 THEN
			FOR wIndex := 0 TO sSnake.length DO
				sSnake.body[sSnake.length - wIndex + 1] := sSnake.body[sSnake.length - wIndex];
			END_FOR;
			sSnake.body[0] := sSnake.shead;
		END_IF;

		IF sFood.pX = sSnake.shead.pX AND sFood.pY = sSnake.shead.pY THEN
			uScore := uScore + 1;

			// food is eaten
			sSnake.body[sSnake.length] := sSnake.shead;
			sSnake.length := sSnake.length + 1;

			// regenerate the food
			REPEAT
				RND(TRUE, sFood.pX);
				RND(TRUE, sFood.pY);

				sFood.pX := sFood.pX MOD WIDTH;
				sFood.pY := sFood.pY MOD HEIGHT;
				FbIsOnSnake(sFood.pX, sFood.pY, bBool);
			UNTIL NOT bBool END_REPEAT;
		END_IF;

		CASE sSnake.dir OF
			wSnakeDirLeft:  sSnake.shead.pX := sSnake.shead.pX - 1;
			wSnakeDirRight: sSnake.shead.pX := sSnake.shead.pX + 1;
			wSnakeDirUp:    sSnake.shead.pY := sSnake.shead.pY - 1;
			wSnakeDirDown:  sSnake.shead.pY := sSnake.shead.pY + 1;
		END_CASE;

		IF    sSnake.shead.pY >= HEIGHT THEN sSnake.shead.pY := 0;
		ELSIF sSnake.shead.pY <  0      THEN sSnake.shead.pY := HEIGHT - 1; END_IF;

		IF    sSnake.shead.pX >= WIDTH  THEN sSnake.shead.pX := 0;
		ELSIF sSnake.shead.pX <  0      THEN sSnake.shead.pX := WIDTH  - 1; END_IF;

		IF wState = wUpdateState THEN wState := wDrawState; END_IF;
		
	wDrawState:
		FbCanvasClear(BLACK);
		FbCanvasSetPixel(sFood.pX, sFood.pY, sFood.color);
		FOR wIndex := 0 TO sSnake.length - 1 DO
			FbCanvasSetPixel(
				sSnake.body[sSnake.length - 1 - wIndex].pX,
				sSnake.body[sSnake.length - 1 - wIndex].pY, BLUE);
		END_FOR;
		FbCanvasSetPixel(sSnake.shead.pX, sSnake.shead.pY, GREEN);
		
		IF wState = wDrawState THEN wState := wRenderState; END_IF;
		
	wRenderState:
		BMOV(wState = wRenderState, aPixelArray, HEIGHT * WIDTH, D0);
		IF wState = wRenderState THEN wState := wSleepState; END_IF;
		                                                                      
	wSleepState:
		TON_1(
			IN := NOT bClock,
			PT := tTimer, Q => bClock);
		IF bClock THEN wState := wEventState; END_IF;
END_CASE;
