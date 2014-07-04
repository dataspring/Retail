Create FUNCTION  [Retail].[Random_Range_With_Default](@start int, @end int, @ValMost int, @ValMostTimes int = 0)

RETURNS int

AS

BEGIN

	DECLARE @rndValue float, @RetValue int, @startIns int, @endIns int, @i int = 0;
	DECLARE @randTable table (id int IDENTITY(0,1), RangeVal int)


	Select @endIns = @end, @startIns = @start

	if (@start < 0 and @end > 0)
	BEGIN
		Select @endIns = @end + -1 * @start, @startIns = 0
		--SET @ValMost = @ValMost + -1 * @start
	END

    IF  @ValMostTimes = 0
		BEGIN
		
			SELECT @rndValue = rndResult
			FROM rndView;
			if (@start < 0 and @end > 0)
				BEGIN
					SET @RetValue = @startIns + @rndValue * (@endIns - @startIns + 1)
					SET @RetValue = @RetValue - (-1 * @start)
				END
			ELSE
				BEGIN
					SET @RetValue = @start + @rndValue * (@end - @start + 1)
				END
		END
	ELSE
		BEGIN
			
			SELECT @rndValue = rndResult
			FROM rndView;

			IF @rndValue * 10 <= @ValMostTimes
				BEGIN
					SET @RetValue =  @ValMost;
				END
			ELSE
				BEGIN
					SELECT @rndValue = rndResult
					FROM rndView;

					if (@start < 0 and @end > 0)
						BEGIN
							SET @RetValue = @startIns + @rndValue * (@endIns - @startIns + 1)
							SET @RetValue = @RetValue - (-1 * @start)
						END
					ELSE
						BEGIN
							SET @RetValue = @start + @rndValue * (@end - @start + 1)
						END
				END
			END

	return @RetValue

END
