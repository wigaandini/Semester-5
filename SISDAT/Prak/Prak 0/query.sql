SELECT f.namafilm, f.tahun, f.durasi, f.imdbrating, COUNT(idkursi) as jumlah_penonton 
FROM _film f
JOIN _reservasi r ON f.idfilm = r.idfilm
WHERE f.tahun < 1998 AND f.imdbrating > 7
GROUP BY f.namafilm, f.tahun, f.durasi, f.imdbrating
HAVING COUNT(idkursi) > 350
ORDER BY f.imdbrating DESC;


CREATE VIEW "marcus_movie" AS 
SELECT DISTINCT f.namafilm AS "Judul", f.imdbrating AS "Rating Film", f.tahun AS "Tahun"
FROM _film f 
JOIN _reservasi r ON f.idfilm = r.idfilm
JOIN _pelanggan p ON r.idpelanggan = p.idpelanggan
WHERE p.namapelanggan LIKE 'Marcus%';


CREATE VIEW "above_avg_genre_penayangan" AS
SELECT g.genre AS "nama_genre", COUNT(p.idfilm) AS "jumlah penayangan"
FROM _genre g
JOIN _film_has_genre fg ON g.genre = fg.genre
JOIN _penayangan p ON fg.idfilm = p.idfilm
GROUP BY g.genre
HAVING COUNT(p.idfilm) > (SELECT AVG(jumlah_genre) FROM 
    (SELECT COUNT(p2.idfilm) as jumlah_genre
    FROM _film_has_genre as fg NATURAL JOIN _penayangan as p2
    GROUP BY fg.genre ));


WITH film_yang_tayang AS (
    SELECT p.idfilm, p.idstudio, p.waktumulai
    FROM _penayangan p
    JOIN _film f ON p.idfilm = f.idfilm
    WHERE p.waktumulai::date = '2011-01-01'
      AND f.imdbrating >= 7
    LIMIT 1
),
veronica_id AS (
    SELECT idpelanggan FROM _pelanggan WHERE namapelanggan = 'Veronica Doheny'
),
insert_reservasi AS (
    INSERT INTO _reservasi (idfilm, idstudio, waktumulai, idkursi, idpelanggan)
    SELECT fy.idfilm, fy.idstudio, fy.waktumulai, 'B6' AS idkursi, vi.idpelanggan
    FROM film_yang_tayang fy, veronica_id vi
    RETURNING idfilm, idstudio, waktumulai, idpelanggan
)
INSERT INTO _reservasi (idfilm, idstudio, waktumulai, idkursi, idpelanggan)
SELECT ir.idfilm, ir.idstudio, ir.waktumulai, 'B7' AS idkursi, ir.idpelanggan
FROM insert_reservasi ir;


SELECT r.idfilm, r.idstudio, r.waktumulai, r.idkursi, p.namapelanggan
FROM _reservasi r
JOIN _pelanggan p ON r.idpelanggan = p.idpelanggan
WHERE p.namapelanggan = 'Veronica Doheny' AND r.waktumulai::date = '2011-01-01';

SELECT * 
FROM _penayangan JOIN _film ON _penayangan.idfilm = _film.idfilm
WHERE waktumulai::date = '2011-01-01';



UPDATE _film
SET imdbrating = 6.00
WHERE imdbrating < 6.00
AND idfilm IN (
    SELECT r.idfilm 
    FROM _reservasi r
    GROUP BY r.idfilm
    HAVING COUNT(r.idkursi) > 500
);


CREATE TABLE _SPG (
    idkaryawan INT REFERENCES _karyawan(idkaryawan),
    idstudio INT REFERENCES _studio(idstudio),
    idfilm INT REFERENCES _film(idfilm),
    PRIMARY KEY (idkaryawan, idstudio, idfilm)
);


CREATE TABLE SPG (
    idkaryawan INT,
    idstudio INT,
    idfilm INT,
    PRIMARY KEY (idkaryawan, idstudio, idfilm),
    CONSTRAINT fk_idkaryawan FOREIGN KEY (idkaryawan) REFERENCES karyawan(idkaryawan),
    CONSTRAINT fk_idstudio FOREIGN KEY (idstudio) REFERENCES _studio(idstudio),
    CONSTRAINT fk_idfilm FOREIGN KEY (idfilm) REFERENCES _film(idfilm)
);


CREATE TABLE karyawan (
    idkaryawan INT PRIMARY KEY,
    namakaryawan VARCHAR(100) NOT NULL
);

ALTER TABLE _studio
ADD CONSTRAINT unique_studio UNIQUE (idstudio);

ALTER TABLE _film
ADD CONSTRAINT unique_film UNIQUE (idfilm);

CREATE TABLE SPG (
    idkaryawan INT REFERENCES karyawan(idkaryawan),
    idstudio INT REFERENCES _studio(idstudio),
    idfilm INT REFERENCES _film(idfilm),
    PRIMARY KEY (idkaryawan, idstudio, idfilm)
);
