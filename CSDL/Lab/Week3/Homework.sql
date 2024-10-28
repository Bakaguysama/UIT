
-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
	SELECT
		TenKyNang,
		CapDo
	FROM KyNang 
	JOIN ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
	WHERE MaChuyenGia = 1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
	SELECT 
		HoTen
	FROM ChuyenGia
	JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
	WHERE MaDuAn = 2;

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
	SELECT 
		TenDuAn,
		TenCongTy
	FROM CongTy
	RIGHT OUTER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
	SELECT 
		ChuyenNganh,
		COUNT(MaChuyenGia) AS  SoLuongChuyenGia
	FROM ChuyenGia
	GROUP BY ChuyenNganh;

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
	SELECT 
		MaChuyenGia,
		HoTen
	FROM ChuyenGia
	WHERE NamKinhNghiem = (
		SELECT MAX(NamKinhNghiem)
		FROM ChuyenGia
	);

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
	SELECT 
		HoTen,
		COUNT(MaDuAn) AS SoLuongDuAn
	FROM ChuyenGia_DuAn
	JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
	GROUP BY HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
	SELECT 
		TenCongTy,
		COUNT(MaDuAn) AS SoLuongDuAn
	FROM CongTy
	JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
	GROUP BY TenCongTy;

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
		SELECT TOP 1
			s.MaKyNang,
			TenKyNang
		FROM ChuyenGia_KyNang e_s
		JOIN KyNang s ON e_s.MaKyNang = s.MaKyNang
		GROUP BY s.MaKyNang, s.TenKyNang
		ORDER BY COUNT(e_s.MaChuyenGia) DESC

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
	SELECT
		HoTen
	FROM ChuyenGia e
	JOIN ChuyenGia_KyNang e_s ON e.MaChuyenGia = e_s.MaChuyenGia
	WHERE MaKyNang = (
		SELECT MaKyNang
		FROM KyNang
		WHERE TenKyNang = 'Python'
	) AND CapDo >= 4;

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
	SELECT TOP 1
		p.MaDuAn,
		p.TenDuAn
	FROM DuAn p 
	JOIN ChuyenGia_DuAn e_p ON p.MaDuAn = e_p.MaDuAn
	GROUP BY p.MaDuAn, p.TenDuAn
	ORDER BY COUNT(MaChuyenGia) DESC;

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
	SELECT 
		ChuyenGia.HoTen,
		COUNT(MaKyNang) AS SoLuongKyNang
	FROM ChuyenGia
	JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
	GROUP BY ChuyenGia.HoTen;

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
	SELECT 
		a.MaChuyenGia AS ChuyenGiaA,
		b.MaChuyenGia AS ChuyenGiaB,
		a.MaDuAn
	FROM ChuyenGia_DuAn a
	JOIN ChuyenGia_DuAn b ON a.MaDuAn = b.MaDuAn
	WHERE a.MaChuyenGia < b.MaChuyenGia;
		
-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
	SELECT 
		HoTen,
		COUNT(MaKyNang) AS SoLuongKyNang
	FROM ChuyenGia e
	JOIN ChuyenGia_KyNang e_s ON e.MaChuyenGia = e_s.MaChuyenGia
	GROUP BY HoTen, CapDo
	HAVING CapDo = 5;
-- 21. Tìm các công ty không có dự án nào.
	SELECT 
		c.MaCongTy,
		TenCongTy
	FROM CongTy c
	LEFT JOIN DuAn p ON c.MaCongTy = p.MaCongTy
	WHERE p.MaDuAn IS NULL;

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
	SELECT 
		HoTen,
		TenDuAn
	FROM ChuyenGia
	LEFT JOIN  ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
	LEFT JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
	SELECT 
		e.MaChuyengia,
		HoTen
	FROM ChuyenGia e
	JOIN ChuyenGia_KyNang e_s ON e.MaChuyenGia = e_s.MaChuyenGia
	GROUP BY e.MaChuyenGia, HoTen
	HAVING COUNT(MaKyNang) >= 3;

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
	SELECT
		TenCongTy,
		SUM(NamKinhNghiem) AS TongSoNamKinhNghiem
	FROM CongTy c
	JOIN DuAn p ON c.MaCongTy = p.MaCongTy
	JOIN ChuyenGia_DuAn e_s ON p.MaDuAn = e_s.MaDuAn
	JOIN ChuyenGia e ON e_s.MaChuyenGia = e.MaChuyenGia
	GROUP BY TenCongTy;

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
	(SELECT 
		e_s.MaChuyenGia,
		HoTen
	FROM ChuyenGia_KyNang e_s
	JOIN KyNang s ON e_s.MaKyNang = s.MaKyNang
	JOIN ChuyenGia e ON e_s.MaChuyenGia = e.MaChuyenGia
	WHERE TenKyNang = 'Java')
	EXCEPT
	(SELECT 
		e_s.MaChuyenGia,
		HoTen
	FROM ChuyenGia_KyNang e_s
	JOIN KyNang s ON e_s.MaKyNang = s.MaKyNang
	JOIN ChuyenGia e ON e_s.MaChuyenGia = e.MaChuyenGia
	WHERE TenKyNang = 'Python');

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
	SELECT TOP 1
		e.MaChuyenGia,
		HoTen
	FROM ChuyenGia e
	JOIN ChuyenGia_KyNang e_s ON e.MaChuyenGia = e_s.MaChuyenGia
	GROUP BY e.MaChuyenGia, HoTen
	ORDER BY COUNT(MaKyNang) DESC;
	
	SELECT 
		e.MaChuyenGia,
		HoTen
	FROM ChuyenGia e
	JOIN ChuyenGia_KyNang e_s ON e.MaChuyenGia = e_s.MaChuyenGia
	GROUP BY e.MaChuyenGia, HoTen
	HAVING COUNT(MaKyNang) = (
		SELECT MAX(CountedSkills)
		FROM (
				SELECT
					COUNT(MaKyNang) AS CountedSkills
				FROM ChuyenGia_KyNang
				GROUP BY MaChuyenGia
		) AS SubQuerry
	);

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
	SELECT 
		a.MaChuyenGia,
		a.HoTen,
		b.MaChuyenGia,
		b.HoTen
	FROM ChuyenGia a
	JOIN ChuyenGia b ON a.ChuyenNganh = b.ChuyenNganh
	WHERE a.MaChuyenGia < b.MaChuyenGia;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
	SELECT TOP 1
		TenCongTy,
		SUM(NamKinhNghiem) AS TongSoNamKinhNghiem
	FROM CongTy c
	JOIN DuAn p ON c.MaCongTy = p.MaCongTy
	JOIN ChuyenGia_DuAn e_s ON p.MaDuAn = e_s.MaDuAn
	JOIN ChuyenGia e ON e_s.MaChuyenGia = e.MaChuyenGia
	GROUP BY TenCongTy
	ORDER BY TongSoNamKinhNghiem DESC;

	SELECT
		TenCongTy,
		SUM(NamKinhNghiem) AS TongSoNamKinhNghiem
	FROM CongTy c
	JOIN DuAn p ON c.MaCongTy = p.MaCongTy
	JOIN ChuyenGia_DuAn e_s ON p.MaDuAn = e_s.MaDuAn
	JOIN ChuyenGia e ON e_s.MaChuyenGia = e.MaChuyenGia
	GROUP BY TenCongTy
	HAVING SUM(NamKinhNghiem) = (
		SELECT MAX(Tong)
		FROM(
			SELECT
				SUM(NamKinhNghiem) AS Tong
			FROM CongTy
			JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
			JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
			JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
			GROUP BY TenCongTy
		) AS SubQuerry
	);

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
	SELECT 
		s.MaKyNang,
		TenKyNang
	FROM KyNang s
	JOIN ChuyenGia_KyNang e_s ON s.MaKyNang = e_s.MaKyNang
	GROUP BY s.MaKyNang, TenKyNang
	HAVING COUNT(DISTINCT MaChuyenGia) = (
		SELECT COUNT(DISTINCT ChuyenGia.MaChuyenGia)
		FROM ChuyenGia
	);