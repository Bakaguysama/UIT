CREATE DATABASE DE2

CREATE TABLE PHONGBAN(
	MaPhong char(5) PRIMARY KEY,
	TenPhong varchar(25),
	TruongPhong char(5)
)

CREATE TABLE NHANVIEN(
	MaNV char(5) PRIMARY KEY,
	HoTen varchar(20),
	NgayVL smalldatetime,
	HSLuong numeric(4,2),
	MaPhong char(5),
	FOREIGN KEY(MaPhong) REFERENCES PHONGBAN(MaPhong)
)

ALTER TABLE PHONGBAN
ADD FOREIGN KEY(TruongPhong) REFERENCES NHANVIEN(MaNV)

CREATE TABLE XE(
	MaXe char(5) PRIMARY KEY,
	LoaiXe varchar(20),
	SoChoNgoi int,
	NamSX int,
)

CREATE TABLE PHANCONG(
	MaPC char(5) PRIMARY KEY,
	MaNV char(5),
	MaXe char(5),
	NgayDi smalldatetime,
	NgayVe smalldatetime,
	NoiDen varchar(25)
	FOREIGN KEY(MaNV) REFERENCES NHANVIEN(MaNV),
	FOREIGN KEY(MaXe) REFERENCES XE(MaXe)
)

-- 2.1
	CREATE TRIGGER TRG_XE_UpdateInsertNamSX ON XE FOR UPDATE, INSERT
	AS BEGIN
		DECLARE @LoaiXe varchar(20), @NamSX int
		
		SELECT @LoaiXe = LoaiXe, @NamSX = NamSX
		FROM inserted

		IF (@LoaiXe = 'Toyota' AND @NamSX < 2006)
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Nam san xuat cua xe Toyota phai tu nam 2006 tro ve sau!', 16, 1)
			END
		ELSE
			BEGIN
				PRINT('Thao tac thanh cong!')
			END
	END
	-----------------------------------------------
	ALTER TABLE XE
	ADD CONSTRAINT CHK_XE CHECK(LoaiXe = 'Toyota' AND NamSX >= 2006)


-- 2.2
/*
			Them		Xoa			Sua
NHANVIEN	-			-			+(MaPhong)
PHONGBAN	-			-			+(TenPhong)
XE			-			-			+(LoaiXe)
PHANCONG	+			-			+(MaNV, MaXe)
*/

	CREATE TRIGGER TRG_PHANCONG_UpdateInsertPhanCongLaiXe ON PHANCONG FOR UPDATE, INSERT
	AS BEGIN
		DECLARE @MaNV char(5), @MaXe char(5), @LoaiXe varchar(20), @TenPhong varchar(25)

		SELECT @MaNV = MaNV, @MaXe = MaXe
		FROM inserted

		SELECT @TenPhong = TenPhong
		FROM PHONGBAN p
		JOIN NHANVIEN nv ON p.MaPhong = nv.MaPhong
		WHERE nv.MaNV = @MaNV

		SELECT @LoaiXe = LoaiXe
		FROM XE x
		WHERE x.MaXe = @MaXe

		IF(@TenPhong = N'Ngoại thành' AND @LoaiXe != 'Toyota')
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Nhan vien thuoc phong lai xe Ngoai thanh chi duoc phan cong lai xe loai Toyota!', 16, 1)
			END
		ELSE
			BEGIN
				PRINT('THAO TAC THANH CONG!')
			END
	END

	CREATE TRIGGER TRG_XE_UpdateLoaiXe ON XE FOR UPDATE
	AS BEGIN
		DECLARE @MaNV char(5), @MaXe char(5), @LoaiXe varchar(20), @TenPhong varchar(25)

		SELECT @MaXe = MaXe, @LoaiXe = LoaiXe
		FROM inserted

		SELECT @MaNV = MaNV
		FROM PHANCONG pc
		JOIN XE x ON x.MaXe = pc.MaXe
		WHERE pc.MaXe = @MaXe

		SELECT @TenPhong = TenPhong
		FROM PHONGBAN p 
		JOIN NHANVIEN nv ON p.MaPhong = nv.MaPhong
		WHERE nv.MaNV = @MaNV

		IF(@TenPhong = N'Ngoại thành' AND @LoaiXe != 'Toyota')
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Nhan vien thuoc phong lai xe Ngoai thanh chi duoc phan cong lai xe loai Toyota!', 16, 1)
			END
		ELSE
			BEGIN
				PRINT('THAO TAC THANH CONG!')
			END
	END

	CREATE TRIGGER TRG_PHONGBAN_UpdateTenPhong ON PHONGBAN FOR UPDATE
	AS BEGIN	

		IF EXISTS(SELECT 1
					FROM PHANCONG pc
					JOIN XE x ON pc.MaXe = x.MaXe
					JOIN NHANVIEN nv ON pc.MaNV = nv.MaNV
					JOIN PHONGBAN p ON nv.MaPhong = p.MaPhong
					WHERE TenPhong = N'Ngoại thành' AND  LoaiXe != 'Toyota'
		)
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Thao tac khong thanh cong!', 16, 1)
			END
		ELSE
			BEGIN
				PRINT('THAO TAC THANH CONG!')
			END
	END
-- 3.1
	SELECT nv.MaNV, HoTen
	FROM NHANVIEN nv
	JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
	JOIN PHANCONG pc ON pc.MaNV = nv.MaNV
	JOIN XE x ON x.MaXe = pc.MaXe
	WHERE TenPhong = N'Nội thành' AND LoaiXe = 'Toyota' AND SoChoNgoi = 4;

-- 3.2
	SELECT nv.MaNV, HoTen
	FROM NHANVIEN nv
	JOIN PHANCONG pc ON nv.MaNV = pc.MaNV
	JOIN XE x ON x.MaXe = pc.MaXe
	WHERE nv.MaNV IN (
		SELECT TruongPhong
		FROM PHONGBAN
	)
	GROUP BY nv.MaNV, HoTen
	HAVING COUNT(DISTINCT x.LoaiXe) = (	
		SELECT COUNT(DISTINCT x2.LoaiXe)
		FROM XE x2
	);

-- 3.3
	SELECT pb.MaPhong, nv.MaNV, HoTen
	FROM PHONGBAN pb
	JOIN NHANVIEN nv ON nv.MaPhong = pb.MaPhong
	JOIN PHANCONG pc ON pc.MaNV = nv.MaNV
	JOIN XE x ON x.MaXe = pc.MaXe
	WHERE LoaiXe = 'Toyota'
	GROUP BY pb.MaPhong, nv.MaNV, HoTen
	HAVING COUNT(pc.MaXe) <= ALL(
		SELECT COUNT(pc2.MaXe)
		FROM NHANVIEN nv2 
		JOIN PHANCONG pc2 ON pc2.MaNV = nv2.MaNV
		JOIN XE x2 ON pc2.MaXe = x2.MaXe
		WHERE nv2.MaPhong = pb.MaPhong AND LoaiXe = 'Toyota'
		GROUP BY nv2.MaNV
	)