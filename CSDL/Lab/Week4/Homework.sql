-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
	SELECT TOP 3
		e.MaChuyenGia,
		HoTen,
		COUNT(MaKyNang) AS SoLuongKyNang
	FROM ChuyenGia e
	JOIN ChuyenGia_KyNang e_s ON e.MaChuyenGia = e_s.MaChuyenGia
	GROUP BY e.MaChuyenGia, HoTen
	ORDER BY SoLuongKyNang DESC;

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
	SELECT 
		a.MaChuyenGia AS MaChuyenGiaA,
		a.HoTen AS HoTenChuyenGiaA,
		b.MaChuyenGia AS MaChuyenGiaB,
		b.HoTen AS HoTenChuyenGiaB
	FROM ChuyenGia a
	JOIN ChuyenGia b ON a.ChuyenNganh = b.ChuyenNganh
	WHERE a.MaChuyenGia < b.MaChuyenGia AND ABS(a.NamKinhNghiem - b.NamKinhNghiem) <=2;

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
	SELECT TenCongTy, COUNT(DISTINCT DuAn.MaDuAn) AS SoLuongDuAn, SUM(NamKinhNghiem) AS TongSoNamKinhNghiem
	FROM CongTy, ChuyenGia_DuAn, ChuyenGia, DuAn
	WHERE CongTy.MaCongTy = DuAn.MaCongTy AND ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn AND ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
	GROUP BY TenCongTy;

	SELECT TenCongTy, COUNT(DISTINCT DuAn.MaDuAn) AS SoLuongDuAn, SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem
	FROM CongTy
	LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
	LEFT JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
	LEFT JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
	GROUP BY TenCongTy;

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
	SELECT ChuyenGia.MaChuyenGia, HoTen
	FROM ChuyenGia, ChuyenGia_KyNang
	WHERE ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia 
	AND ChuyenGia.MaChuyenGia NOT IN(
		SELECT MaChuyenGia
		FROM ChuyenGia_KyNang
		WHERE CapDo < 3
	) 
	GROUP BY ChuyenGia.MaChuyenGia, HoTen
	HAVING COUNT(ChuyenGia.MaChuyenGia) >= 1 AND ChuyenGia.MaChuyenGia IN (
		SELECT MaChuyenGia
		FROM ChuyenGia_KyNang
		WHERE CapDo = 5
	) 

	SELECT DISTINCT ChuyenGia.MaChuyenGia, HoTen
	FROM ChuyenGia
	JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
	WHERE ChuyenGia.MaChuyenGia IN (
		SELECT MaChuyenGia
		FROM ChuyenGia_KyNang
		WHERE CapDo = 5
	) AND ChuyenGia.MaChuyenGia NOT IN (
		SELECT MaChuyenGia
		FROM ChuyenGia_KyNang
		WHERE CapDo < 3
	)

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
	SELECT ChuyenGia.MaChuyenGia, HoTen, COUNT(MaDuAn) AS SoLuongDuAn
	FROM ChuyenGia
	LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
	GROUP BY ChuyenGia.MaChuyenGia, HoTen;

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
	WITH Sub AS (
		SELECT
			ChuyenGia.MaChuyenGia,
			HoTen,
			LoaiKyNang,
			CapDo,
			ROW_NUMBER() OVER (PARTITION BY LoaiKyNang ORDER BY CapDo DESC) Ranking
			FROM ChuyenGia
			JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
			JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
	)
	SELECT 
		MaChuyenGia,
		HoTen,
		LoaiKyNang,
		CapDo
	FROM Sub 
	WHERE Ranking = 1;

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
	WITH Career AS(
		SELECT ChuyenNganh, COUNT(*) AS SLChuyenNganh
		FROM ChuyenGia
		GROUP BY ChuyenNganh
	),

	Expert AS(
		SELECT COUNT(MaChuyenGia) AS SLChuyenGia
		FROM ChuyenGia
	)
	SELECT 
		ChuyenNganh,
		SLChuyenNganh,
		CAST(SLChuyenNganh AS FLOAT) / SLChuyenGia * 100 AS 'TyLe(%)'
	FROM Career, Expert;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
	WITH Freq AS(
		SELECT
			e_s1.MaKyNang AS KyNang1,
			e_s2.MaKyNang AS KyNang2,
			COUNT(*) AS TanSuatXuatHien
		FROM ChuyenGia_KyNang e_s1
		JOIN ChuyenGia_KyNang e_s2 
		ON e_s1.MaChuyenGia = e_s2.MaChuyenGia AND e_s1.MaKyNang < e_s2.MaKyNang
		GROUP BY e_s1.MaKyNang, e_s2.MaKyNang
	)
	SELECT TOP 5
		s1.TenKyNang AS TenKyNang1,
		s2.TenKyNang AS TenKyNang2,
		TanSuatXuatHien
	FROM Freq 
	JOIN KyNang s1 ON Freq.KyNang1 = s1.MaKyNang
	JOIN KyNang s2 ON Freq.KyNang2 = s2.MaKyNang
	ORDER BY TanSuatXuatHien DESC;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
	WITH Sub AS(
		SELECT 
			TenCongTy,
			DATEDIFF(DAY, NgayBatDau, NgayKetThuc) AS SoNgay
			FROM CongTy
			JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
	)
	SELECT
		TenCongTy,
		AVG(SoNgay) AS SoNgayTrungBinh
	FROM Sub 
	GROUP BY TenCongTy;

	SELECT 
    CongTy.TenCongTy,
    AVG(DATEDIFF(day, DuAn.NgayBatDau, DuAn.NgayKetThuc)) AS TrungBinhSoNgay
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.MaCongTy, CongTy.TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
	WITH KyNangDocDao AS
	(
		SELECT
			a.MaChuyenGia,
			HoTen,
			COUNT(MaKyNang) AS SoLuongKyNangDocDao
		FROM ChuyenGia a
		JOIN ChuyenGia_KyNang ON a.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
		WHERE MaKyNang NOT IN (
			SELECT 
				DISTINCT MaKyNang
			FROM ChuyenGia_KyNang b
			WHERE a.MaChuyenGia != b.MaChuyenGia
		)
		GROUP BY a.MaChuyenGia, HoTen
	)

	SELECT TOP 1
		MaChuyenGia,
		HoTen,
		SoLuongKyNangDocDao
	FROM KyNangDocDao
	GROUP BY MaChuyenGia, HoTen, SoLuongKyNangDocDao
	ORDER BY SoLuongKyNangDocDao DESC;

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
	SELECT 
		RANK() OVER(ORDER BY COUNT(DISTINCT MaDuAn) DESC, SUM (CapDo) DESC) AS Ranking,
		ChuyenGia.MaChuyenGia,
		HoTen,
		COUNT(DISTINCT MaDuAn) AS SoDuAn,
		SUM (CapDo) AS TongCapDoKyNang
	FROM ChuyenGia
	LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
	JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
	GROUP BY ChuyenGia.MaChuyenGia, HoTen;

	WITH ProjectCount AS (
    SELECT MaChuyenGia, COUNT(*) AS SoLuongDuAn
    FROM ChuyenGia_DuAn
    GROUP BY MaChuyenGia
),
SkillLevelSum AS (
    SELECT MaChuyenGia, SUM(CapDo) AS TongCapDoKyNang
    FROM ChuyenGia_KyNang
    GROUP BY MaChuyenGia
)
SELECT 
    ChuyenGia.HoTen,
    COALESCE(ProjectCount.SoLuongDuAn, 0) AS SoLuongDuAn,
    COALESCE(SkillLevelSum.TongCapDoKyNang, 0) AS TongCapDoKyNang,
    RANK() OVER (ORDER BY COALESCE(ProjectCount.SoLuongDuAn, 0) + COALESCE(SkillLevelSum.TongCapDoKyNang, 0) DESC) AS XepHang
FROM ChuyenGia
LEFT JOIN ProjectCount ON ChuyenGia.MaChuyenGia = ProjectCount.MaChuyenGia
LEFT JOIN SkillLevelSum ON ChuyenGia.MaChuyenGia = SkillLevelSum.MaChuyenGia;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
	SELECT 
		DuAn.MaDuAn,
		TenDuAn
	FROM DuAn
	JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
	JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
	GROUP BY DuAn.MaDuAn,TenDuAn
	HAVING COUNT(ChuyenNganh) = (
		SELECT COUNT(DISTINCT ChuyenNganh)
		FROM ChuyenGia
	)

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
	WITH DuAnHoanThanh AS (
		SELECT 
			TenCongTy AS CongTyCoDuAnHoanThanh,
			CongTy.MaCongTy,
			COUNT(DISTINCT MaDuAn) AS SoLuongDuAnHoanThanh
		FROM CongTy
		JOIN DuAn ON CongTy.MaCongTy = DuAn.MaDuAn
		WHERE TrangThai = N'Hoàn thành'
		GROUP BY TenCongTy
	),

	TongSoDuAN AS (
		SELECT 
			COUNT(*) AS TongDuAn
		FROM DuAn
	)

	SELECT 
		CongTy.TenCongTy,
		CAST(SoLuongDuAnHoanThanh AS FLOAT) / TongDuAn * 100 AS TyLeThanhCong
	FROM CongTy, DuAnHoanThanh, TongSoDuAN
	WHERE CongTy.MaCongTy = DuAnHoanThanh.MaCongTy;

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
	WITH CapDoKyNang AS
	(
		SELECT
			ChuyenGia.MaChuyenGia,
			HoTen,
			MaKyNang,
			CapDo,
			ROW_NUMBER() OVER(PARTITION BY ChuyenGia.MaChuyenGia ORDER BY CapDo DESC) SkillLevel,
			ROW_NUMBER() OVER(PARTITION BY ChuyenGia.MaChuyenGia ORDER BY CapDo ASC) ReversedSkillLevel
		FROM ChuyenGia
		JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
	)

	SELECT 
		a.HoTen AS HoTenChuyenGia1,
		b.HoTen AS HoTenChuyenGia2,
		s1.TenKyNang AS KyNang1,
		s2.TenKyNang AS KyNang2
	FROM CapDoKyNang a
	JOIN CapDoKyNang b ON
		a.MaChuyenGia != b.MaChuyenGia
		AND a.SkillLevel = 1 
		AND b.ReversedSkillLevel = 1
		AND a.MaKyNang = b.MaKyNang
	JOIN KyNang s1 ON s1.MaKyNang = a.MaKyNang
	JOIN CapDoKyNang a2 ON
		a2.MaChuyenGia = a.MaChuyenGia
		AND a2.ReversedSkillLevel = 1
	JOIN CapDoKyNang b2 ON
		b2.MaChuyenGia = b.MaChuyenGia
		AND b2.SkillLevel = 1
		AND a2.MaKyNang = b2.MaKyNang
	JOIN KyNang s2 ON s2.MaKyNang = a2.MaKyNang
	WHERE a.MaChuyenGia < b.MaChuyenGia;

	