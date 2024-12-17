CREATE DATABASE DE1

CREATE TABLE TACGIA(
	MaTG char(5) PRIMARY KEY,
	HoTen varchar(20),
	DiaChi varchar(50),
	NgSinh smalldatetime,
	SoDT varchar(15)
)

CREATE TABLE SACH(
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai varchar(25)
)

CREATE TABLE TACGIA_SACH(
	MaTG char(5),
	MaSach char(5),
	PRIMARY KEY(MaTG, MaSach),
	FOREIGN KEY(MaTG) REFERENCES TACGIA(MaTG),
	FOREIGN KEY(MaSach) REFERENCES SACH(MaSach)
)

CREATE TABLE PHATHANH(
	MaPH char(5) PRIMARY KEY,
	MaSach char(5),
	NgayPH smalldatetime,
	SoLuong int,
	NhaXuatBan varchar(20),
	FOREIGN KEY(MaSach) REFERENCES SACH(MaSach)
)

-- 2.1
	CREATE TRIGGER TRG_PHATHANH_UpdateInsert ON PHATHANH FOR UPDATE, INSERT
	AS BEGIN
		DECLARE @MaSach char(5), @NgayPH smalldatetime, @NgSinh smalldatetime

		SELECT @MaSach = MaSach, @NgayPH = NgayPH
		FROM inserted

		SELECT @NgSinh = NgSinh
		FROM TACGIA tg
		JOIN TACGIA_SACH tg_s ON tg.MaTG = tg.MaTG
		WHERE MaSach = @MaSach

		IF(@NgSinh > @NgayPH)
			BEGIN 
				ROLLBACK TRAN
				RAISERROR('Ngay sinh phai nho hon ngay phat hanh', 16,1)
			END
		ELSE
			BEGIN
				PRINT('THAO TAC THANH CONG!')
			END
	END

	CREATE TRIGGER TRG_TACGIA_UpdateInsert ON TACGIA FOR UPDATE
	AS BEGIN
		DECLARE @NgSinh smalldatetime, @MaTG char(5), @NgayPH smalldatetime

		SELECT @NgSinh = NgSinh, @MaTG = MaTG
		FROM inserted

		SELECT @NgayPH = MIN(NgayPH)
		FROM PHATHANH ph
		JOIN TACGIA_SACH tg_s ON tg_s.MaSach = ph.MaSach
		JOIN TACGIA tg ON tg.MaTG = tg_s.MaTG
		WHERE tg.MaTG = @MaTG
		
		IF (@NgayPH < @NgSinh)
			BEGIN 
					ROLLBACK TRAN
					RAISERROR('Ngay sinh phai nho hon ngay phat hanh', 16,1)
				END
			ELSE
				BEGIN
					PRINT('THAO TAC THANH CONG!')
				END
	END

-- 2.2
	CREATE TRIGGER TRG_SACH_UPDATE ON SACH FOR UPDATE
	AS BEGIN
		DECLARE @TheLoai varchar(20), @MaSach char(5), @NXB varchar(20)

		SELECT @TheLoai = TheLoai, @MaSach = MaSach
		FROM inserted

		SELECT @NXB = NhaXuatBan
		FROM PHATHANH
		WHERE MaSach = @MaSach

		IF(@TheLoai = N'Giáo khoa' AND @NXB = N'Giáo dục')
			BEGIN
				PRINT('THAO TAC THANH CONG!')
			END
		ELSE
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Sach thuoc the loai Giao khoa chi do nha xuat ban Giai duc phat hanh!', 16, 1)
			END
	END

	CREATE TRIGGER TRG_PHATHANH_UPDATEINSERT2 ON PHATHANH FOR UPDATE,INSERT
	AS BEGIN
		DECLARE @TheLoai varchar(20), @MaSach char(5), @NXB varchar(20)

		SELECT @NXB = NhaXuatBan, @MaSach = MaSach
		FROM inserted

		SELECT @TheLoai = TheLoai
		FROM SACH
		WHERE MaSach = @MaSach

		IF(@TheLoai = N'Giáo khoa' AND @NXB = N'Giáo dục')
			BEGIN
				PRINT('THAO TAC THANH CONG!')
			END
		ELSE
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Sach thuoc the loai Giao khoa chi do nha xuat ban Giai duc phat hanh!', 16, 1)
			END
	END
-- 3.1
	SELECT
		tg.MaTG, HoTen, SoDT
	FROM TACGIA tg
	JOIN TACGIA_SACH tg_s ON tg.MaTG = tg_s.MaTG
	JOIN SACH s ON s.MaSach = tg_s.MaSach
	JOIN PHATHANH ph ON s.MaSach = ph.MaSach
	WHERE TheLoai = N'Văn học' AND NhaXuatBan = N'Trẻ';

-- 3.2
	SELECT TOP 1 WITH TIES
		NhaXuatBan
	FROM PHATHANH ph
	JOIN SACH s ON ph.MaSach = s.MaSach
	GROUP BY NhaXuatBan
	ORDER BY COUNT(DISTINCT TheLoai) DESC;
-- 3.3
	SELECT NhaXuatBan, tg.MaTG, HoTen
	FROM PHATHANH ph
	JOIN TACGIA_SACH tg_s ON ph.MaSach = tg_s.MaSach
	JOIN TACGIA tg ON tg_s.MaTG = tg.MaTG
	GROUP BY NhaXuatBan, tg.MaTG, HoTen
	HAVING COUNT(ph.MaSach) >= ALL(
		SELECT COUNT(ph2.MaSach)
		FROM PHATHANH ph2
		JOIN TACGIA_SACH tg_s2 ON ph2.MaSach = tg_s2.MaSach
		WHERE ph2.NhaXuatBan = ph.NhaXuatBan
		GROUP BY tg_s2.MaTG
	)