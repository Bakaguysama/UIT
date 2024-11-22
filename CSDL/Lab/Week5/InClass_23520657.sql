--Bài tập 1: Sinh viên hoàn thành Phần I bài tập QuanLyBanHang từ câu 11 đến 14. 

/*Câu 11: Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó 
đăng ký thành viên (NGDK). */
	CREATE TRIGGER TRIGGER_HOADON_NGHD ON HOADON FOR INSERT
	AS 
	BEGIN
		DECLARE @NgayHD smalldatetime, @MaKH char(4), @NgayDK smalldatetime

		SELECT @NgayHD = NGHD,
			   @MaKH = MaKH
		FROM inserted

		SELECT @NgayDK = NGDK
		FROM KHACHHANG
		WHERE MAKH = @MaKH

		IF (@NgayHD < @NgayDK)
		BEGIN
			PRINT 'LOI: NGAY HOA DON KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			PRINT 'THEM MOI MOT HOA DON THANH CONG'
		END
	END;

	CREATE TRIGGER TRG_HOADON_NGHD_UPDATE ON HOADON FOR UPDATE
	AS 
	BEGIN
		DECLARE @NgayHD smalldatetime, @MaKH char(4), @NgayDK smalldatetime

		SELECT @NgayHD = NGHD,
			   @MaKH = MaKH
		FROM inserted

		SELECT @NgayDK = NGDK
		FROM KHACHHANG
		WHERE MAKH = @MaKH

		IF (@NgayHD < @NgayDK)
		BEGIN
			PRINT 'LOI: NGAY HOA DON KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			PRINT 'SUA HOA DON THANH CONG'
		END
	END

/*Câu 12: Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm. */
	CREATE TRIGGER TRIGGER_HOADON_NGHD_NV ON HOADON FOR INSERT
	AS
	BEGIN
		DECLARE @NgayHD smalldatetime, @MANV char(4), @NgayVL smalldatetime

		SELECT @NgayHD = NGHD,
			   @MANV = MANV
		FROM inserted

		SELECT @NgayVL = NGVL
		FROM NHANVIEN
		WHERE @MANV = MANV

		IF (@NgayHD < @NgayVL)
		BEGIN
			PRINT('LOI: HOA DON KHONG HOP LE!')
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			PRINT('THEM MOI MOT HOA DON THANH CONG!')
		END
	END

	CREATE TRIGGER TRIGGER_HOADON_NGHD_NV_UPDATE ON HOADON FOR UPDATE
	AS
	BEGIN
		DECLARE @NgayHD smalldatetime, @MANV char(4), @NgayVL smalldatetime

		SELECT @NgayHD = NGHD,
			   @MANV = MANV
		FROM inserted

		SELECT @NgayVL = NGVL
		FROM NHANVIEN
		WHERE @MANV = MANV

		IF (@NgayHD < @NgayVL)
		BEGIN
			PRINT('LOI: HOA DON KHONG HOP LE!')
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			PRINT('SUA HOA DON THANH CONG!')
		END
	END

/*Câu 13: Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.*/
	CREATE TRIGGER TRG_CTHD ON CTHD
	FOR INSERT, UPDATE, DELETE
	AS 
	BEGIN 
	DECLARE @TRIGIA money, @MASP char(4), @SOHD int, @SL int
	SELECT @SOHD = SOHD, @MASP = MASP, @SL = SL FROM INSERTED
	SET @TRIGIA = @SL * (SELECT GIA FROM SANPHAM WHERE MASP = @MASP)
	DECLARE CUR_CTHD CURSOR
	FOR 
		SELECT MASP, SL
		FROM CTHD
		WHERE SOHD = @SOHD
	OPEN CUR_CTHD
	FETCH NEXT FROM CUR_CTHD
	INTO @MASP, @SL

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	SET @TRIGIA = @TRIGIA + @SL * (SELECT GIA FROM SANPHAM WHERE MASP = @MASP)
	FETCH NEXT FROM CUR_CTHD
	INTO @MASP, @SL
	END
	CLOSE CUR_CTHD
	DEALLOCATE CUR_CTHD
	UPDATE HOADON SET TRIGIA = @TRIGIA WHERE SOHD = @SOHD
	END

/*Câu 14: Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.*/
	CREATE TRIGGER TRG_HOADON ON HOADON FOR INSERT, UPDATE, DELETE
	AS BEGIN
		DECLARE @SoHD int, @MaKH char(4), @TriGia money, @DoanhSo money

		SELECT @SoHD = SOHD, @MaKH = MAKH, @TriGia = TRIGIA
		FROM inserted

		SET @DoanhSo = @TriGia

		DECLARE CUR_HOADON CURSOR 
		FOR 
			SELECT TRIGIA
			FROM HOADON
			WHERE SOHD = @SoHD
		OPEN CUR_HOADON
		FETCH NEXT FROM CUR_HOADON INTO @TriGia

		WHILE (@@FETCH_STATUS = 0)
			BEGIN 
				SET	@DoanhSo = @DoanhSo + @TriGia
				FETCH NEXT FROM CUR_HOADON INTO @TriGia
				CLOSE CUR_HOADON
				DEALLOCATE CUR_HOADON
			END

		UPDATE KHACHHANG SET DOANHSO = @DoanhSo WHERE MAKH = @MAKH
	END;

    
--Bài tập 2: Sinh viên hoàn thành Phần I bài tập QuanLyGiaoVu câu 9, 10 và từ câu 15 đến câu 24.

/*Câu 9: Lớp trưởng của một lớp phải là học viên của lớp đó.*/
	CREATE TRIGGER TRG_LOP_INSERT_UPDATE ON LOP FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @Malop char(3), @MaLopTruong char(5)
		SELECT @Malop = MALOP
		FROM inserted

		SELECT @MaLopTruong = TRGLOP
		FROM LOP
		WHERE MALOP = @Malop

		IF (CHARINDEX(@Malop, @MaLopTruong) != 1)
			BEGIN
				PRINT 'LOI: LOP TRUONG KHONG HOP LE'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'THEM MOI MOT LOP TRUONG THANH CONG'
			END
	END;

	CREATE TRIGGER TRG_HOCVIEN_DELETE ON HOCVIEN FOR DELETE
	AS BEGIN
		IF EXISTS (SELECT 1 FROM deleted d
				   JOIN LOP l
				   ON d.MALOP = l.MALOP
				   WHERE l.TRGLOP = d.MAHV
		)
			BEGIN 
				PRINT 'LOI: KHONG THE XOA HOC VIEN DANG LA LOP TRUONG!'
				ROLLBACK TRAN
			END
	END;


/*Câu 10: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.*/
	CREATE TRIGGER TRG_KHOA_TRGKHOA_INSERT ON KHOA FOR INSERT, UPDATE
	AS BEGIN 
		DECLARE @MaKhoa varchar(4), @TRGKhoa char(4), @HocVi varchar(10), @MaGV char(4)
		SELECT @MaKhoa = MAKHOA, @TRGKhoa = TRGKHOA
		FROM inserted
		
		SELECT @HocVi = HOCVI
		FROM GIAOVIEN
		WHERE MAGV = @MaGV

		SELECT @MaGV = TRGKHOA
		FROM KHOA 
		WHERE MAKHOA = @MaKhoa

		IF ((SELECT gv.MAKHOA
				FROM GIAOVIEN gv , KHOA k
				WHERE gv.MAKHOA = k.MAKHOA
				 AND k.TRGKHOA = gv.MAGV AND gv.MAGV = @MaGV
				 ) != @MaKhoa OR @TRGKhoa != @MaGV OR @HocVi NOT IN ('TS','PTS'))
				BEGIN 
					PRINT 'LOI: TRUONG KHOA KHONG HOP LE'
					ROLLBACK TRAN
				END
		ELSE
				BEGIN
					PRINT 'THEM MOI MOT TRUONG KHOA THANH CONG'
				END
	END 



/*Câu 15: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.*/
	CREATE TRIGGER TRG_KETQUATHI_INSERT ON KETQUATHI FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MaHV char(5), @MaMH varchar(10), @NgayThi smalldatetime, @NgayKTMon smalldatetime

		SELECT @MaHV = MAHV, @NgayThi = NGTHI
		FROM inserted
		
		SELECT @NgayKTMon = DENNGAY
		FROM GIANGDAY
		WHERE MAMH = @MaMH

		SELECT @MAMH = MAMH 
		FROM GIANGDAY
		WHERE @MAHV = (
			SELECT MAHV
			FROM HOCVIEN
			WHERE MAHV = @MaHV
		)

		IF (@NgayThi < @NgayKTMon)
			BEGIN
				PRINT 'LOI: NGAY THI KHONG HOP LE!'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'THEM MOI MOT KET QUA THI THANH CONG!'
			END
	END

	CREATE TRIGGER TRG_GIANGDAY_UPDATE_DENNGAY ON GIANGDAY FOR UPDATE
	AS BEGIN 
		DECLARE @NgayKT smalldatetime, @MaHV char(5), @MaMH varchar(10), @NgayThi smalldatetime, @MaLop char(3)

		SELECT @NgayKT = DENNGAY, @MaMH = MAMH, @MaLop = MALOP
		FROM inserted

		SELECT @MaHV = MAHV
		FROM HOCVIEN
		WHERE MALOP = @MaLop

		SELECT @NgayThi = NGTHI
		FROM KETQUATHI
		WHERE MAMH = @MaMH AND MAHV = @MaHV

		IF (@NgayKT > @NgayThi)
			BEGIN
				PRINT 'LOI: NGAY THI KHONG HOP LE!'
				ROLLBACK TRAN
			END
	END;

/*Câu 16: Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.*/
	CREATE TRIGGER TRG_GIANGDAY_INSERT ON GIANGDAY FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MaLop char(3), @SoMon int

		SELECT 
			   @MaLop = MALOP
		FROM inserted

		SELECT @SoMon = COUNT(MaMH) 
		FROM GIANGDAY GD1
		WHERE HOCKY IN (SELECT HOCKY
					FROM GIANGDAY GD2
					WHERE GD1.NAM = GD2.NAM
						AND GD1.HOCKY = GD2.HOCKY) AND MALOP = @MaLop
		GROUP BY MALOP,HOCKY,NAM

		IF (@SoMon > 3)
			BEGIN
				PRINT 'LOI: VUOT SO MON TOI DA!'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'THEM MOI MOT CONG TAC GIANG DAY THANH CONG'
			END
	END;



/*Câu 17: Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó. */
	CREATE TRIGGER TRG_LOP_INSERT ON HOCVIEN FOR INSERT
	AS BEGIN
		DECLARE @SoLuongHV tinyint, @MaLop char(3), @SiSo tinyint

		SELECT @SiSo = MAHV, @MaLop = MALOP
		FROM inserted

		SELECT @SoLuongHV = (
			SELECT COUNT(DISTINCT MAHV)
			FROM HOCVIEN
			WHERE MALOP = @MaLop
		)

		IF (@SiSo != @SoLuongHV)
			BEGIN
				PRINT 'LOI: SI SO KHONG HOP LE!'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'THEM MOT LOP THANH CONG!'
			END
	END;

	CREATE TRIGGER TRG_HOCVIEN_INSERT_UPDATE ON HOCVIEN FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @SoLuongHV tinyint, @MaLop char(3), @SiSo tinyint

		SELECT  @MaLop = MALOP
		FROM inserted

		SELECT @SiSo = SISO
		FROM LOP
		WHERE MALOP = @MaLop
		
		SELECT @SoLuongHV = (
			SELECT COUNT(DISTINCT MAHV)
			FROM HOCVIEN
			WHERE MALOP = @MaLop
		)

		IF (@SiSo != @SoLuongHV)
			BEGIN
				PRINT 'LOI: SI SO KHONG HOP LE!'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'THEM MOT LOP THANH CONG!'
			END
	END


/*Câu 18: Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng 
một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và 
(“B”,”A”). */

	CREATE TRIGGER TRG_DIEUKIEN_INSERT ON DIEUKIEN FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MonHocS varchar(10), @MonHocTrc varchar(10), @SoCapMon int
		
		SELECT @MonHocS = MAMH, @MonHocTrc = MAMH_TRUOC
		FROM inserted

		IF (@MonHocTrc = @MonHocS OR @MonHocTrc IN (SELECT MAMH FROM DIEUKIEN WHERE MAMH_TRUOC = @MonHocS))
			BEGIN
				PRINT 'LOI: DIEU KIEN MON KHONG HOP LE!'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'THEM MOT DIEU KIEN THANH CONG!'
			END
	END;


/*Câu 19: Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.*/
	CREATE TRIGGER TRG_GIAOVIEN_INSERT_UPDATE ON GIAOVIEN FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MaGV char(4), @HocVi varchar(10), @HocHam varchar(10), @HeSo numeric(4,2), @Luong money
		
		SELECT @MaGV = MAGV, @HocVi = HOCVI, @HocHam = HOCHAM, @HeSo = HESO, @Luong = MUCLUONG
		FROM inserted

		IF (@Luong != (SELECT MUCLUONG 
						  FROM GIAOVIEN
						  WHERE HOCVI = @HocVi AND HOCHAM = @HocHam AND HESO = @HeSo AND MAGV != @MaGV))
			BEGIN 
				PRINT 'LOI: DIEU KIEN MUC LUONG CUA GIAO VIEN KHONG HOP LE!'
				ROLLBACK TRAN
			END
	END;

/*Câu 20: Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5. */
	ALTER TRIGGER TRG_KETQUATHI_INSERT_LANTHI ON KETQUATHI FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MaHV char(5), @MaMH varchar(10), @LanThiSau tinyint, @Diem numeric(4,2), @LanThiTruoc tinyint

		SELECT @MaHV = MAHV, @MaMH = MAMH, @LanThiSau = LANTHI
		FROM inserted
		
		SELECT @LanThiTruoc = (
			SELECT COUNT(LANTHI)
			FROM KETQUATHI
			WHERE MAHV = @MaHV AND MAMH = @MaMH
		)

		SELECT @Diem = (
			SELECT DIEM
			FROM KETQUATHI
			WHERE LANTHI = @LanThiTruoc AND MAHV = @MaHV AND MAMH = @MaMH
		)

		IF (@LanThiSau > 1 AND @Diem < 5)
			BEGIN
				PRINT 'THAO TAC THANH CONG!'
			END
		ELSE
			BEGIN
				PRINT 'LOI: LAN THI KHONG HOP LE!'
				ROLLBACK TRAN
			END
	END;

/*Câu 21: Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn 
học).*/
	CREATE TRIGGER TRG_KETQUATHI_INSERT_UPDATE_NGAYTHI ON KETQUATHI FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MaHV char(5), @MaMH varchar(10), @NgayThiTr smalldatetime, @LanThiTr tinyint, @NgayThiS smalldatetime, @LanThiS tinyint

		SELECT @MaHV = MAHV, @MaMH = MAMH, @NgayThiS = NGTHI, @LanThiS = LANTHI
		FROM inserted

		SELECT @LanThiTr = (
			SELECT COUNT(LANTHI)
			FROM KETQUATHI
			WHERE MAHV = @MaHV AND MAMH = @MaMH
		)

		SELECT @NgayThiTr = (
			SELECT NGTHI
			FROM KETQUATHI
			WHERE LANTHI = @LanThiTr AND MAHV = @MaHV AND MAMH = @MaMH
		)

		IF (@NgayThiS >= @NgayThiTr )
			BEGIN 
				PRINT 'THAO TAC THANH CONG!'
			END
		ELSE
			BEGIN 
				PRINT 'LOI: LAN THI KHONG HOP LE!'
				ROLLBACK TRAN
			END
	END;


/*Câu 22: Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau 
khi học xong những môn học phải học trước mới được học những môn liền sau). */
	CREATE TRIGGER TRG_GIANGDAY_UPDATE_INSERT_DIEUKIENDAY ON GIANGDAY FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MaLop char(3), @MaGV char(4), @MaMH varchar(10)
		SELECT @MaLop = MALOP, @MaGV = MAGV, @MaMH = MAMH FROM INSERTED
		IF EXISTS (SELECT 1 FROM DIEUKIEN DK 
					LEFT JOIN KETQUATHI KQT ON DK.MAMH_TRUOC = KQT.MAMH 
					   AND KQT.MAHV IN (SELECT MAHV FROM HOCVIEN WHERE MALOP = @MALOP)
						WHERE DK.MAMH = @MAMH)
			BEGIN
				PRINT 'THAO TAC THANH CONG!'
			END
		ELSE
			BEGIN
				PRINT 'LOI: CAC MON HOC TRUOC KHONG DUNG DIEU KIEN!'
				ROLLBACK TRAN
			END
	END



/*Câu 23: Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.*/
	CREATE TRIGGER TRG_GIANGDAY_UPDATE_INSERT_MONHOC ON GIANGDAY FOR INSERT, UPDATE
	AS BEGIN
		DECLARE @MaMH varchar(10), @MaGV char(4), @MaKhoaGV varchar(4), @MaKhoaMonHoc varchar(4)

		SELECT @MaMH = MAMH, @MaGV = MAGV
		FROM inserted

		SELECT @MaKhoaGV = (
			SELECT MAKHOA
			FROM GIAOVIEN
			WHERE MAGV = @MaGV
		)

		SELECT @MaKhoaMonHoc = (
			SELECT MAKHOA
			FROM MONHOC
			WHERE MAMH = @MaMH
		)

		IF (@MaKhoaMonHoc != @MaKhoaGV)
			BEGIN
				PRINT 'LOI: MA KHOA CUA GIAO VIEN KHONG GIONG MA KHOA CUA MON HOC DO GIAO VIEN DO PHU TRACH!'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'THAO TAC THANH CONG!'
			END
	END;

