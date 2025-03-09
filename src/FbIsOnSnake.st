bResult := FALSE;

FOR wIndex := 0 TO sSnake.length DO
	IF pX = sSnake.body[wIndex].pX AND pY = sSnake.body[wIndex].pY THEN
		bResult := TRUE;
		RETURN;
	END_IF;
END_FOR;
