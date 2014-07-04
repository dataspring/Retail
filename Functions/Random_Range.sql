CREATE FUNCTION  [Retail].[Random_Range](@start int, @end int)

RETURNS int

AS

BEGIN
  
	DECLARE @rndValue float;

	SELECT @rndValue = rndResult
	FROM rndView;

	return @start + @rndValue * (@end - @start + 1)

END

