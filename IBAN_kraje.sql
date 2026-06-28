create function sprawdziban_kazdykraj (@iban varchar(34))
returns int
as
begin
    set @iban = upper(@iban)

    if len(@iban) < 15 or len(@iban) > 34 or left(@iban, 2) like '%[^A-Z]%'
        return 0

    declare @przesuniety varchar(34) = substring(@iban, 5, len(@iban) - 4) + left(@iban, 4)

    declare @numerycznyiban varchar(100) = ''
    declare @j int = 1
    declare @znak char(1)

    while @j <= len(@przesuniety)
    begin
        set @znak = substring(@przesuniety, @j, 1)
        
        if @znak like '[0-9]'
            set @numerycznyiban = @numerycznyiban + @znak
        else if @znak like '[A-Z]'
            set @numerycznyiban = @numerycznyiban + cast(ascii(@znak) - 55 as varchar(2))
        else
            return 0
            
        set @j = @j + 1
    end

    declare @mod int = 0
    declare @i int = 1
   
    while @i <= len(@numerycznyiban)
    begin
        set @mod = (@mod * 10 + cast(substring(@numerycznyiban, @i, 1) as int)) % 97
        set @i = @i + 1
    end

    if @mod = 1
        return 1
    
    return 0
end

select dbo.sprawdziban_kazdykraj('CH4479122017039130481')
select dbo.sprawdziban_kazdykraj ('PL83105084313569503199613608')
select dbo.sprawdziban_kazdykraj ('ES4813833285146856210547')
-- Szwajcaria (CH) - zmieniona ostatnia cyfra z 1 na 2
select dbo.sprawdziban_kazdykraj('CH4479122017039130482')

-- Polska (PL) - zmieniona ostatnia cyfra z 8 na 9
select dbo.sprawdziban_kazdykraj('PL83105084313569503199613609')

-- Hiszpania (ES) - zmieniona ostatnia cyfra z 7 na 8
select dbo.sprawdziban_kazdykraj('ES4813833285146856210548')

-- Wielka Brytania (GB) - z literami w środku, zmieniona ostatnia cyfra z 0 na 1
select dbo.sprawdziban_kazdykraj('GB82MIDL40231644781441')
