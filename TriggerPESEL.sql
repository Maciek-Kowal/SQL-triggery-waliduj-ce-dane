create table klienci (
    id int identity(1,1) primary key,
    pesel char(11) not null,
    data_urodzenia date not null,
    plec char(1) not null
)

create trigger trg_sprawdzpeselklienci
on klienci
after insert, update
as
begin
    declare @pesel char(11)
    declare @data_urodzenia date
    declare @plec char(1)
    declare @suma int
    declare @przesuniecie_miesiaca int
    declare @oczekiwane_6_cyfr varchar(6)
    declare @cyfra_plci int

    select top 1 @pesel = pesel, @data_urodzenia = data_urodzenia, @plec = plec 
    from inserted

    if @pesel is null return

    if (len(@pesel) = 11 and @pesel not like '%[^0-9]%')
    begin
        set @suma = 
            cast(substring(@pesel, 1, 1) as tinyint) * 1 +
            cast(substring(@pesel, 2, 1) as tinyint) * 3 +
            cast(substring(@pesel, 3, 1) as tinyint) * 7 +
            cast(substring(@pesel, 4, 1) as tinyint) * 9 +
            cast(substring(@pesel, 5, 1) as tinyint) * 1 +
            cast(substring(@pesel, 6, 1) as tinyint) * 3 +
            cast(substring(@pesel, 7, 1) as tinyint) * 7 +
            cast(substring(@pesel, 8, 1) as tinyint) * 9 +
            cast(substring(@pesel, 9, 1) as tinyint) * 1 +
            cast(substring(@pesel, 10, 1) as tinyint) * 3
            
        if ((10 - (@suma % 10)) % 10 <> cast(substring(@pesel, 11, 1) as tinyint))
        begin
            print 'blad: nieprawidlowa suma kontrolna pesel'
            rollback
            return
        end
    end
    else
    begin
        print 'blad: pesel musi miec dokladnie 11 cyfr i same liczby'
        rollback
        return
    end

    set @przesuniecie_miesiaca = (((year(@data_urodzenia) / 100) % 5) * 20 + 20) % 100
    set @oczekiwane_6_cyfr = 
        right(cast(year(@data_urodzenia) as varchar(4)), 2) + 
        right('0' + cast(month(@data_urodzenia) + @przesuniecie_miesiaca as varchar(3)), 2) + 
        right('0' + cast(day(@data_urodzenia) as varchar(2)), 2)

    if (substring(@pesel, 1, 6) <> @oczekiwane_6_cyfr)
    begin
        print 'blad: podana data urodzenia nie zgadza sie z numerem pesel'
        rollback
        return
    end

    set @cyfra_plci = cast(substring(@pesel, 10, 1) as int)

    if (@plec = 'K' and @cyfra_plci % 2 <> 0) or (@plec = 'M' and @cyfra_plci % 2 = 0)
    begin
        print 'blad: podana plec nie zgadza sie ze znakiem w numerze pesel'
        rollback 
        return
    end
end
go

-- test 1: poprawny pesel (mezczyzna, ur. 31 grudnia 1999)
insert into klienci (pesel, data_urodzenia, plec) 
values ('99123101233', '1999-12-31', 'M')
print 'test 1 ok'

-- test 2: poprawny pesel z przesunieciem na stulecie (kobieta, ur. 15 maja 2024)
insert into klienci (pesel, data_urodzenia, plec) 
values('24251500001', '2024-05-15', 'K')
print 'test 2 ok'

-- test 3: zla suma kontrolna (ostatnia cyfra to 4, a powinna byc 3)
insert into klienci (pesel, data_urodzenia, plec) values ('99123101234', '1999-12-31', 'M')

-- test 4: zla data urodzenia (inny dzien niz w pesel)
insert into klienci (pesel, data_urodzenia, plec) values ('99123101233', '1999-12-30', 'M')

-- test 5: zla plec (pesel wskazuje na mezczyzne, wprowadzono 'K')
insert into klienci (pesel, data_urodzenia, plec) values ('99123101233', '1999-12-31', 'K')

-- test 6: inne stulecie niz w pesel (pesel to maj 2024, wprowadzono 1924)
insert into klienci (pesel, data_urodzenia, plec) values ('24251500001', '1924-05-15', 'K')

-- sprawdzenie finalne (w tabeli beda 2 rekordy)
 select * from klienci