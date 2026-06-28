alter function SprawdzIban (@iban varchar(34))
returns int
as
begin
    if len(@iban) = 28 and left(@iban, 2) = 'PL'
    begin
        if substring(@iban, 3, 26) like '%[^0-9]%'
            return 0

        declare @numerycznyiban varchar(30) = substring(@iban, 5, 24) + '2521' + substring(@iban, 3, 2)

        declare @mod int = 0
        declare @i int = 1
        
        while @i <= len(@numerycznyiban)
        begin
            set @mod = (@mod * 10 + cast(substring(@numerycznyiban, @i, 1) as int)) % 97
            set @i = @i + 1
        end

        if @mod = 1
            return 1
        else
            return 0
    end
    
    return 0
end

select dbo.SprawdzIban('PL65105079002383419269299526') as CzyJest