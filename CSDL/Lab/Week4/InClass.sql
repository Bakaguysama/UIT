--Bài tập 1: Sinh viên hoàn thành Phần III bài tập QuanLyBanHang từ câu 19 đến 30. 

/*Câu 19: Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?*/
	SELECT COUNT(HOADON.SOHD) AS SoLuongHoaDon
	FROM HOADON
	WHERE MAKH IS NULL;
	
	SELECT COUNT(HOADON.SOHD) AS SoLuongHoaDon
	FROM HOADON
	WHERE HOADON.MAKH NOT IN (
		SELECT MAKH 
		FROM KHACHHANG
		WHERE HOADON.MAKH = KHACHHANG.MAKH
	);

/*Câu 20: Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006. */
	SELECT COUNT(DISTINCT MASP) AS SoLuongSanPham
	FROM CTHD 
	JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
	WHERE YEAR(NGHD) = 2006;

/*Câu 21: Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu? */
	SELECT 
		CAST(MAX(TRIGIA) AS INT) AS TriGiaCaoNhat,
		CAST(MIN(TRIGIA) AS INT) AS TriGiaThapNhat
	FROM HOADON

/*Câu 22: Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu? */
	SELECT AVG(TRIGIA) AS TriGiaTrungBinh
	FROM HOADON
	WHERE YEAR(NGHD) = 2006;
	
/*Câu 23: Tính doanh thu bán hàng trong năm 2006. */
	SELECT CAST(SUM(TRIGIA) AS BIGINT) AS DoanhThu
	FROM HOADON
	WHERE YEAR(NGHD) = 2006;

/*Câu 24: Tìm số hóa đơn có trị giá cao nhất trong năm 2006. */
	SELECT SOHD
	FROM HOADON
	WHERE YEAR(NGHD) = 2006 AND TRIGIA = (
		SELECT MAX(TRIGIA)
		FROM HOADON
	);

/*Câu 25: Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006. */
	SELECT MAKH
	FROM HOADON
	WHERE YEAR(NGHD) = 2006 AND TRIGIA = (
		SELECT MAX(TRIGIA)
		FROM HOADON
	);

/*Câu 26: In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.  */
	SELECT DISTINCT TOP 3 
		MAKH,
		HOTEN,
		DOANHSO
	FROM KHACHHANG
	GROUP BY MAKH, HOTEN, DOANHSO
	ORDER BY DOANHSO DESC;

/*Câu 27: In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.  */
	SELECT 
		MASP,
		TENSP,
		GIA
	FROM SANPHAM
	WHERE GIA IN (
		SELECT DISTINCT TOP 3
			GIA
		FROM SANPHAM
		ORDER BY GIA DESC
	);

/*Câu 28: In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức 
giá cao nhất (của tất cả các sản phẩm).  */
	SELECT 
		MASP,
		TENSP,
		GIA
	FROM SANPHAM
	WHERE NUOCSX = 'Thai Lan' AND GIA IN (
		SELECT DISTINCT TOP 3
			GIA
		FROM SANPHAM
		ORDER BY GIA DESC
	);

/*Câu 29: In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức 
giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).  */
	SELECT 
		MASP,
		TENSP,
		GIA
	FROM SANPHAM
	WHERE NUOCSX = 'Trung Quoc' AND GIA IN (
		SELECT DISTINCT TOP 3
			GIA
		FROM SANPHAM
		WHERE NUOCSX = 'Trung Quoc'
		ORDER BY GIA DESC
	);

/*Câu 30: In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).  */
	SELECT DISTINCT  TOP 3
		ROW_NUMBER() OVER(ORDER BY DOANHSO DESC) AS Ranking,
		*
	FROM KHACHHANG;

--Bài tập 2: Sinh viên hoàn thành Phần III bài tập QuanLyGiaoVu từ câu 19 đến câu 25. 

/*Câu 19: Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. */
	SELECT 
		MAKHOA,
		TENKHOA
	FROM KHOA
	WHERE NGTLAP = (
		SELECT MIN(NGTLAP)
		FROM KHOA
	);

/*Câu 20: Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.  */
	SELECT 
		COUNT(MAGV) AS SoLuongGiaoVien
	FROM GIAOVIEN
	WHERE HOCHAM IN ('GS', 'PGS');

/*Câu 21: Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi 
khoa.  */
	SELECT 
		TENKHOA,
		HOCVI,
		COUNT(MAGV) AS SoLuongGiaoVien
	FROM GIAOVIEN
	JOIN KHOA ON GIAOVIEN.MAKHOA = KHOA.MAKHOA
	WHERE HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS', 'PTS')
	GROUP BY TENKHOA, HOCVI;

	SELECT MAKHOA, HOCVI, COUNT(HOCVI) SL FROM GIAOVIEN 
	GROUP BY MAKHOA, HOCVI
	ORDER BY MAKHOA

/*Câu 22: Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).  */
	SELECT 
		MAMH,
		KQUA,
		COUNT(MAHV) AS SoLuongHocVien
	FROM KETQUATHI
	GROUP BY MAMH, KQUA;

/*Câu 23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho 
lớp đó ít nhất một môn học.  */
	SELECT 
		MAGV,
		HOTEN
	FROM GIAOVIEN
	WHERE MAGV IN (
		SELECT MAGVCN FROM LOP
		WHERE EXISTS (
			SELECT 1 FROM GIANGDAY
			WHERE GIANGDAY.MAGV = LOP.MAGVCN AND LOP.MALOP = GIANGDAY.MALOP
		)
	)

	SELECT MAGV, HOTEN 
FROM GIAOVIEN 
WHERE MAGV IN(
	SELECT DISTINCT MAGV
	FROM GIANGDAY GD INNER JOIN LOP
	ON GD.MALOP = LOP.MALOP
	WHERE MAGV = MAGVCN 
)

/*Câu 24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.  */
	SELECT 
		HO + ' ' + TEN AS HOTEN
	FROM HOCVIEN
	WHERE MAHV IN (
		SELECT TRGLOP
		FROM LOP
		WHERE SISO = (
			SELECT MAX(SISO)
			FROM LOP
		)
	);

	SELECT HO + ' ' + TEN HOTEN FROM LOP INNER JOIN HOCVIEN HV
ON LOP.TRGLOP = HV.MAHV
WHERE SISO = (
	SELECT MAX(SISO) FROM LOP
)

/*Câu 25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả 
các lần thi).  */
	SELECT 
		HO + ' ' + TEN AS HOTEN
	FROM HOCVIEN 
	WHERE MAHV IN (
		SELECT MAHV FROM KETQUATHI A
		WHERE MAHV IN (
			SELECT TRGLOP FROM LOP
		) AND NOT EXISTS(
			SELECT * 
			FROM KETQUATHI B
			WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
		) AND KQUA = N'Khong Dat'
		GROUP BY MAHV
		HAVING COUNT(MAMH) >= 3
	);

	SELECT 
		HO + ' ' + TEN AS HOTEN
	FROM HOCVIEN
	JOIN LOP ON HOCVIEN.MAHV = LOP.TRGLOP
	WHERE MAHV IN (
		SELECT MAHV 
		FROM KETQUATHI 
		WHERE LANTHI = 3 AND KQUA = N'Khong Dat'
		GROUP BY MAHV
		HAVING COUNT(MAMH) >= 3
	)

--Bài tập 3: Sinh viên hoàn thành Phần III bài tập QuanLyBanHang từ câu 31 đến 45. 

/*Câu 31: Tính tổng số sản phẩm do “Trung Quoc” sản xuất.  */
	SELECT 
		NUOCSX,
		COUNT(MASP) AS TongSoSanPham
	FROM SANPHAM
	WHERE NUOCSX = 'Trung Quoc'
	GROUP BY NUOCSX;

/*Câu 32: Tính tổng số sản phẩm của từng nước sản xuất. */
		SELECT 
		NUOCSX,
		COUNT(MASP) AS TongSoSanPham
	FROM SANPHAM
	GROUP BY NUOCSX;

/*Câu 33: Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.  */
	SELECT 
		NUOCSX,
		MAX(GIA) AS GiaBanCaoNhat,
		MIN(GIA) AS GiaBanThapNhat,
		AVG(GIA) AS GiaBanTrungBinh
	FROM SANPHAM
	GROUP BY NUOCSX;

/*Câu 34: Tính doanh thu bán hàng mỗi ngày. */
	SELECT 
		NGHD,
		SUM(TRIGIA) AS DoanhThu
	FROM HOADON
	GROUP BY NGHD;

/*Câu 35: Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006. */
	SELECT
		MASP,
		SUM(SL) AS TongSoLuongSanPham
	FROM CTHD
	JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
	WHERE MONTH(NGHD) = 10 AND YEAR(NGHD) = 2006
	GROUP BY MASP;

/*Câu 36: Tính doanh thu bán hàng của từng tháng trong năm 2006. */
	SELECT 
		MONTH(NGHD) AS Thang,
		SUM(TRIGIA) AS DoanhThu
	FROM HOADON 
	WHERE YEAR(NGHD) = 2006
	GROUP BY MONTH(NGHD);

/*Câu 37: Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau. */
	SELECT
		HOADON.SOHD
	FROM HOADON
	LEFT JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
	GROUP BY HOADON.SOHD
	HAVING COUNT(DISTINCT MASP) >= 4
	
/*Câu 38: Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).  */
	SELECT
		HOADON.SOHD
	FROM HOADON
	LEFT JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
	JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
	WHERE NUOCSX = 'Viet Nam'
	GROUP BY HOADON.SOHD
	HAVING COUNT(DISTINCT CTHD.MASP) = 3

/*Câu 39: Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.  */
	SELECT TOP 1
		KHACHHANG.MAKH,
		HOTEN,
		COUNT(DISTINCT SOHD) AS SoLanMuaHang
	FROM KHACHHANG
	JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
	GROUP BY KHACHHANG.MAKH, HOTEN
	ORDER BY COUNT(DISTINCT SOHD) DESC;

/*Câu 40: Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ? */
	SELECT TOP 1 WITH TIES
		MONTH(NGHD) AS Thang,
		SUM(TRIGIA) AS DoanhThu
	FROM HOADON 
	WHERE YEAR(NGHD) = 2006
	GROUP BY MONTH(NGHD)
	ORDER BY SUM(TRIGIA) DESC;

/*Câu 41: Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.  */
	SELECT TOP 1 WITH TIES
		CTHD.MASP,
		TENSP,
		SUM(SL) AS TongSoLuong
	FROM SANPHAM
	JOIN CTHD ON SANPHAM.MASP = CTHD.MASP
	JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
	WHERE YEAR(NGHD) = 2006
	GROUP BY CTHD.MASP, TENSP
	ORDER BY SUM(SL) ASC;

/*Câu 42: *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất. */
	WITH topSanPham AS
	(	SELECT 
			ROW_NUMBER() OVER (PARTITION BY NUOCSX ORDER BY GIA DESC) AS Ranking,
			NUOCSX,
			MASP,
			TENSP,
			GIA
		FROM SANPHAM
	)

	SELECT 
		NUOCSX,
		MASP,
		TENSP,
		GIA
	FROM topSanPham
	WHERE Ranking = 1;

/*Câu 43: Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.  */
	SELECT 
		NUOCSX
	FROM SANPHAM 
	GROUP BY NUOCSX
	HAVING COUNT(DISTINCT GIA) >= 3
	
/*Câu 44: *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất. */
	WITH TopKhachHang AS
	(
		SELECT TOP 10
			MAKH,
			SUM(TRIGIA) AS DoanhThu
		FROM HOADON 
		WHERE MAKH IS NOT NULL
		GROUP BY MAKH
		ORDER BY SUM(TRIGIA) DESC
	)

	SELECT TOP 1 WITH TIES
		KHACHHANG.MAKH,
		HOTEN,
		COUNT(DISTINCT SOHD) AS SoLanMuaHang
	FROM TopKhachHang
	JOIN KHACHHANG ON TopKhachHang.MAKH = KHACHHANG.MAKH
	JOIN HOADON ON TopKhachHang.MAKH = HOADON.MAKH
	GROUP BY KHACHHANG.MAKH, HOTEN
	ORDER BY COUNT(DISTINCT SOHD) DESC;

--Bài tập 4: Sinh viên hoàn thành Phần III bài tập QuanLyGiaoVu từ câu 26 đến câu 35.

/*Câu 26: Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.  */
	SELECT TOP 1 WITH TIES
		HOCVIEN.MAHV,
		HO + ' ' + TEN AS HOTEN,
		COUNT(DISTINCT MAMH) AS SoMon
	FROM HOCVIEN
	JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
	WHERE DIEM IN (9, 10)
	GROUP BY HOCVIEN.MAHV, HO + ' ' + TEN
	ORDER BY COUNT(DISTINCT MAMH) DESC;

/*Câu 27: Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.  */
	WITH HocVienGioi AS
	(
		SELECT 
			MALOP,
			HOCVIEN.MAHV,
			HO + ' ' + TEN AS HOTEN,
			COUNT(DISTINCT MAMH) AS SoMonHoc,
			ROW_NUMBER() OVER(PARTITION BY MALOP ORDER BY COUNT( DISTINCT MAMH) DESC) AS Ranking
		FROM HOCVIEN
		JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
		WHERE DIEM IN (9, 10)
		GROUP BY MALOP, HOCVIEN.MAHV, HO + ' ' + TEN
	)
	SELECT 
		LOP.MALOP,
		MAHV,
		HOTEN,
		SoMonHoc
	FROM LOP
	LEFT JOIN HocVienGioi ON LOP.MALOP = HocVienGioi.MALOP
	WHERE Ranking = 1;

/*Câu 28: Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao 
nhiêu lớp.  */
	SELECT 
		HOCKY,
		NAM,
		GIAOVIEN.MAGV,
		COUNT(DISTINCT MAMH) AS SoMonHoc,
		COUNT(DISTINCT MALOP) AS SoLop
	FROM GIAOVIEN
	FULL JOIN GIANGDAY ON GIAOVIEN.MAGV = GIAOVIEN.MAGV
	GROUP BY HOCKY, NAM, GIAOVIEN.MAGV;

/*Câu 29: Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất. */
	WITH TimGiaoVien AS
	(
		SELECT 
			NAM,
			HOCKY,
			GIAOVIEN.MAGV,
			COUNT(DISTINCT MALOP) AS SoLop,
			COUNT(DISTINCT MAMH) AS SoMon,
			ROW_NUMBER() OVER(PARTITION BY HOCKY, NAM ORDER BY COUNT(DISTINCT MALOP) DESC, COUNT(DISTINCT MAMH)) AS Ranking
		FROM GIAOVIEN
		JOIN GIANGDAY ON GIAOVIEN.MAGV = GIAOVIEN.MAGV
		GROUP BY NAM, HOCKY, GIAOVIEN.MAGV
	)

	SELECT
		NAM,
		HOCKY,
		MAGV,
		SoLop,
		SoMon
	FROM TimGiaoVien 
	WHERE Ranking = 1
	GROUP BY NAM, HOCKY, MAGV, SoLop, SoMon
	ORDER BY NAM ASC, HOCKY ASC;

/*Câu 30: Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) 
nhất.  */
	SELECT TOP 1 WITH TIES
		MONHOC.MAMH,
		TENMH,
		COUNT(DISTINCT MAHV) AS SoHocVien
	FROM MONHOC
	JOIN KETQUATHI ON MONHOC.MAMH = KETQUATHI.MAMH
	WHERE LANTHI = 1 AND KQUA = N'Khong Dat'
	GROUP BY MONHOC.MAMH, TENMH
	ORDER BY COUNT(DISTINCT MAHV) DESC;

/*Câu 31: Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).  */
	SELECT 
		a.MAHV,
			HO + ' ' + TEN AS HOTEN
	FROM KETQUATHI a
	JOIN HOCVIEN ON a.MAHV  = HOCVIEN.MAHV
	WHERE LANTHI = 1 AND KQUA = N'Dat'
	GROUP BY a.MAHV, HO + ' ' + TEN
	HAVING COUNT(MAMH) = (
		SELECT 
			COUNT(DISTINCT MAMH)
		FROM KETQUATHI b
		WHERE a.MAHV = b.MAHV
		GROUP BY MAHV
	);

	SELECT A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI 
	WHERE LANTHI = 1 AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV


/*Câu 32: * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).  */
	SELECT 
		a.MAHV,
		HO + ' ' + TEN AS HOTEN
	FROM KETQUATHI a
	JOIN HOCVIEN ON a.MAHV  = HOCVIEN.MAHV
	WHERE LANTHI >= 1 AND KQUA = N'Dat'
	GROUP BY a.MAHV, HO + ' ' + TEN
	HAVING COUNT(DISTINCT MAMH) = (
		SELECT 
			COUNT(DISTINCT MAMH)
		FROM KETQUATHI b
		WHERE a.MAHV = b.MAHV
		GROUP BY MAHV
	);

/*Câu 33: * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1). */
	SELECT 
		a.MAHV,
		HO + ' ' + TEN AS HOTEN
	FROM KETQUATHI a
	JOIN HOCVIEN ON a.MAHV  = HOCVIEN.MAHV
	WHERE LANTHI = 1 AND KQUA = N'Dat'
	GROUP BY a.MAHV, HO + ' ' + TEN
	HAVING COUNT(MAMH) = (
		SELECT 
			COUNT(DISTINCT MAMH)
		FROM KETQUATHI b
		WHERE a.MAHV = b.MAHV
	GROUP BY MAHV
	)

/*Câu 34: Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau 
cùng).  */
SELECT C.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI A
	WHERE NOT EXISTS (
		SELECT 1 FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) C INNER JOIN HOCVIEN HV
ON C.MAHV = HV.MAHV;

	WITH LatestAttempts AS
	(
		SELECT 
			MAHV,
			MAMH,
			MAX(LANTHI) AS LastLanThi
		FROM KETQUATHI
		GROUP BY MAHV, MAMH
	)
	SELECT 
		a.MAHV,
		HO + ' ' + TEN AS HOTEN
	FROM KETQUATHI a
	JOIN LatestAttempts b ON a.MAHV = b.MAHV AND a.MAMH = b.MAMH AND a.LANTHI = b.LastLanThi
	JOIN HOCVIEN ON a.MAHV = HOCVIEN.MAHV
	WHERE a.KQUA = N'Dat'
	GROUP BY a.MAHV, HO + ' ' + TEN
	HAVING COUNT(DISTINCT a.MAMH) = (
		SELECT COUNT(DISTINCT MAMH) 
		FROM KETQUATHI
	);

	SELECT 
		a.MAHV,
		HO + ' ' + TEN AS HOTEN
	FROM KETQUATHI a
	JOIN HOCVIEN ON a.MAHV  = HOCVIEN.MAHV
	WHERE LANTHI >= 1 AND KQUA = N'Dat'
	GROUP BY a.MAHV, HO + ' ' + TEN
	HAVING COUNT(DISTINCT MAMH) = (
		SELECT 
			COUNT(DISTINCT MAMH)
		FROM KETQUATHI b
		WHERE a.MAHV = b.MAHV
		GROUP BY MAHV
	);

/*Câu 35: ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần 
thi sau cùng). */
	WITH HighestMark AS
	(
		SELECT
			MAMH,
			MAHV,
			DIEM,
			LANTHI,
			ROW_NUMBER() OVER(PARTITION BY MAMH ORDER BY DIEM DESC) AS Ranking
		FROM KETQUATHI a
		WHERE LANTHI = (
			SELECT
				MAX(LANTHI)
			FROM KETQUATHI b
			WHERE a.MAHV = b.MAHV AND a.MAMH = b.MAMH
		)
	)

	SELECT
		MONHOC.MAMH,
		HOCVIEN.MAHV,
		HO + ' ' + TEN AS HOTEN
	FROM MONHOC
	LEFT OUTER JOIN HighestMark ON MONHOC.MAMH = HighestMark.MAMH
	JOIN HOCVIEN ON HighestMark.MAHV = HOCVIEN.MAHV
	WHERE Ranking = 1;

	SELECT A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT B.MAMH, MAHV, DIEM, DIEMMAX
	FROM KETQUATHI B INNER JOIN (
		SELECT MAMH, MAX(DIEM) DIEMMAX FROM KETQUATHI
		GROUP BY MAMH
	) C 
	ON B.MAMH = C.MAMH
	WHERE NOT EXISTS (
		SELECT 1 FROM KETQUATHI D 
		WHERE B.MAHV = D.MAHV AND B.MAMH = D.MAMH AND B.LANTHI < D.LANTHI
	) AND DIEM = DIEMMAX
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV