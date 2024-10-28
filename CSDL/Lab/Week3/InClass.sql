--Bài tập 1:

/*Câu 12: Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số 
lượng từ 10 đến 20. */
	SELECT 
		 DISTINCT SOHD
	FROM CTHD 
	WHERE MASP IN ('BB01', 'BB02') AND (SL BETWEEN 10 AND 20);

/*Câu 13: Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với 
số lượng từ 10 đến 20.*/
	(SELECT SOHD 
		FROM CTHD
		WHERE MASP = 'BB01' AND (SL BETWEEN 10 AND 20))
	INTERSECT
	(SELECT SOHD 
		FROM CTHD
		WHERE MASP = 'BB02' AND (SL BETWEEN 10 AND 20))

--Bài tập 2:

/*Câu 1: Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.*/
	UPDATE GIAOVIEN
	SET HESO = HESO + 0.2
	WHERE MAGV IN (SELECT TRGKHOA FROM KHOA)

/*Câu 2: Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các 
môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau 
cùng). */
	UPDATE HOCVIEN 
	SET DIEMTB = DTB_HOCVIEN.DTB
	FROM HOCVIEN LEFT JOIN (
		SELECT MAHV,
				AVG(DIEM) AS DTB
		FROM KETQUATHI A
		WHERE NOT EXISTS (
				SELECT 1
				FROM KETQUATHI B
				WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
		)
		GROUP BY MAHV
	)	DTB_HOCVIEN
	ON HOCVIEN.MAHV = DTB_HOCVIEN.MAHV;

/*Câu 3: Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất 
kỳ thi lần thứ 3 dưới 5 điểm. */
	UPDATE HOCVIEN
	SET GHICHU = 'Cam thi'
	WHERE MAHV IN (
		SELECT MAHV 
		FROM KETQUATHI
		WHERE LANTHI = 3 AND DIEM < 5
	)

/*Câu 4: Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau: 
o Nếu DIEMTB >= 9 thì XEPLOAI =”XS” 
o Nếu  8 <= DIEMTB < 9 thì XEPLOAI = “G” 
o Nếu  6.5 <= DIEMTB < 8 thì XEPLOAI = “K” 
o Nếu  5  <=  DIEMTB < 6.5 thì XEPLOAI = “TB” 
o Nếu  DIEMTB < 5 thì XEPLOAI = ”Y”   */
	UPDATE HOCVIEN
	SET XEPLOAI = CASE
	WHEN (DIEMTB >= 9) THEN 'XS'
	WHEN (DIEMTB >= 8 AND DIEMTB < 9) THEN 'G'
	WHEN (DIEMTB >= 6.5 AND DIEMTB < 8) THEN 'K'
	WHEN (DIEMTB >= 5 AND DIEMTB < 6.5) THEN 'TB'
	ELSE 'Y'
	END;

--Bài tập 3: 

/*Câu 6: Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 
2006.*/
	SELECT
		TENMH
	FROM MONHOC
	JOIN GIANGDAY ON MONHOC.MAMH = GIANGDAY.MAMH
	JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
	WHERE HOTEN = N'Tran Tam Thanh' AND HOCKY = 1 AND NAM = 2006;

/*Câu 7: Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy 
trong học kỳ 1 năm 2006.*/
	SELECT
		s.MAMH,
		TENMH
	FROM MONHOC s
	JOIN GIANGDAY t ON s.MAMH = t.MAMH
	WHERE MAGV = (
		SELECT MAGVCN
		FROM LOP
		WHERE MALOP = N'K11'
	) 
	AND HOCKY = 1 AND NAM = 2006;

/*Câu 8: Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So 
Du Lieu”.*/
	SELECT
		HO + ' ' + TEN AS HOTEN
	FROM HOCVIEN
	JOIN LOP ON HOCVIEN.MAHV = LOP.TRGLOP
	JOIN GIANGDAY ON GIANGDAY.MALOP = LOP.MALOP
	JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
	JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
	WHERE GIAOVIEN.HOTEN = N'Nguyen To Lan' AND TENMH = N'Co So Du Lieu';

/*Câu 9: In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So 
Du Lieu”*/
	SELECT 
		mh_truoc.MAMH,
		mh_truoc.TENMH
	FROM MONHOC mh_chinh
	JOIN DIEUKIEN ON mh_chinh.MAMH = DIEUKIEN.MAMH
	JOIN MONHOC mh_truoc ON DIEUKIEN.MAMH_TRUOC = mh_truoc.MAMH
	WHERE mh_chinh.TENMH = N'Co So Du Lieu';

/*Câu 10: Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, 
tên môn học) nào.*/
	SELECT 
		mh_chinh.MAMH,
		mh_chinh.TENMH
	FROM MONHOC mh_chinh
	JOIN DIEUKIEN ON mh_chinh.MAMH = DIEUKIEN.MAMH
	JOIN MONHOC mh_truoc ON DIEUKIEN.MAMH_TRUOC = mh_truoc.MAMH
	WHERE mh_truoc.TENMH = N'Cau Truc Roi Rac';

--Bài tập 4:

/* Câu 14: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được 
bán ra trong ngày 1/1/2007.*/
	(SELECT 
		MASP,
		TENSP
	FROM SANPHAM
	WHERE NUOCSX = 'Trung Quoc')
	UNION
	(	SELECT
		CTHD.MASP,
		TENSP
		FROM CTHD
		JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
		JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
		WHERE NGHD = '1/1/2007'
	);

/* Câu 15: In ra danh sách các sản phẩm (MASP,TENSP) không bán được.*/
	SELECT 
		SANPHAM.MASP,
		TENSP
	FROM SANPHAM
	LEFT JOIN CTHD ON SANPHAM.MASP = CTHD.MASP
	WHERE SOHD IS NULL;

/* Câu 16: In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.*/
	SELECT 
		SANPHAM.MASP,
		TENSP
	FROM SANPHAM
	WHERE SANPHAM.MASP NOT IN (
		SELECT CTHD.MASP
		FROM CTHD
		JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
		WHERE YEAR(NGHD) = 2006
	);

/* Câu 17: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong 
năm 2006.*/
	SELECT 
		SANPHAM.MASP,
		TENSP
	FROM SANPHAM
	WHERE SANPHAM.NUOCSX = 'Trung Quoc' AND SANPHAM.MASP NOT IN (
		SELECT CTHD.MASP
		FROM CTHD
		JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
		WHERE YEAR(NGHD) = 2006
	)

/* Câu 18: Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.*/
	SELECT 
		HOADON.SOHD
	FROM HOADON
	JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
	JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
	WHERE YEAR(NGHD) = 2006 AND NUOCSX = 'Singapore'
	GROUP BY HOADON.SOHD
	HAVING COUNT(DISTINCT SANPHAM.MASP) >= (
		SELECT COUNT(*)
		FROM SANPHAM
		WHERE NUOCSX = 'Singapore'
	);

--Bài 5:

/* Câu 11: Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 
năm 2006.*/
	(SELECT 
		HOTEN
	FROM GIAOVIEN
	JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
	WHERE MAMH = N'CTRR' AND MALOP = N'K11' AND NAM = 2006)
	INTERSECT
	(SELECT 
		HOTEN
	FROM GIAOVIEN
	JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
	WHERE MAMH = N'CTRR' AND MALOP = N'K12' AND NAM = 2006);

/* Câu 12: Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng 
chưa thi lại môn này.*/
	SELECT
		HOCVIEN.MAHV,
		HO + ' ' + TEN AS HOTEN
	FROM HOCVIEN
	WHERE HOCVIEN.MAHV IN (
		SELECT MAHV FROM KETQUATHI A
		WHERE NOT EXISTS (
				SELECT 1 FROM KETQUATHI B
				WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
		) AND MAMH = N'CSDL' AND LANTHI = 1 AND KQUA = N'Khong Dat'
	);

/* Câu 13: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào. */
	SELECT 
		GIAOVIEN.MAGV,
		HOTEN
	FROM GIAOVIEN
	WHERE GIAOVIEN.MAGV NOT IN (
		SELECT DISTINCT MAGV FROM GIANGDAY
	);

/* Câu 14: Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào 
thuộc khoa giáo viên đó phụ trách. */
	SELECT 
		MAGV,
		HOTEN
	FROM GIAOVIEN
	WHERE MAGV NOT IN (
		SELECT DISTINCT GIANGDAY.MAGV 
		FROM GIANGDAY
		JOIN GIAOVIEN ON GIANGDAY.MAGV = GIANGDAY.MAGV
		JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
		WHERE GIAOVIEN.MAKHOA = MONHOC.MAKHOA
	);

/* Câu 15: Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” 
hoặc thi lần thứ 2 môn CTRR được 5 điểm. */
	SELECT HO + ' ' + TEN AS HOTEN FROM HOCVIEN
	WHERE MAHV IN (
	SELECT MAHV FROM KETQUATHI A
	WHERE MALOP = N'K11' AND ((
		NOT EXISTS (
			SELECT 1 FROM KETQUATHI B 
			WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
		)  AND LANTHI >= 3 AND KQUA = 'Khong Dat'
	) OR MAMH = 'CTRR' AND LANTHI = 2 AND DIEM = 5)
);

/* Câu 16: Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm 
học. */
	SELECT HOTEN 
	FROM GIAOVIEN 
	WHERE MAGV IN (
	SELECT MAGV FROM GIANGDAY 
	WHERE MAMH = 'CTRR'
	GROUP BY MAGV, HOCKY, NAM 
	HAVING COUNT(MALOP) >= 2);

/* Câu 17: Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng). */
		SELECT HV.MAHV, HO + ' ' + TEN AS HOTEN, DIEM 
		FROM HOCVIEN HV INNER JOIN (
			SELECT MAHV, DIEM 
			FROM KETQUATHI A
			WHERE NOT EXISTS (
				SELECT 1 
				FROM KETQUATHI B 
				WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
			) AND MAMH = 'CSDL'
		) DIEM_CSDL
		ON HV.MAHV = DIEM_CSDL.MAHV;

/* Câu 18: Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần 
thi).*/
	SELECT 
		HV.MAHV,
		HO + ' ' + TEN AS HOTEN,
		MAX(DIEM) AS DIEMCAONHAT
	FROM HOCVIEN HV 
	JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
	JOIN MONHOC MH ON KQ.MAMH = MH.MAMH
	WHERE TENMH = N'Co So Du Lieu'
	GROUP BY HV.MAHV, HV.HO, HV.TEN, KQ.MAMH;
