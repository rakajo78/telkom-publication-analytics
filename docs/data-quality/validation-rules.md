# Aturan validasi CORE/MART

- Identitas penulis: gunakan ID eksternal stabil (SINTA, Google Scholar, Scopus) jika tersedia; nama saja bukan kunci pasti.
- Publikasi: DOI ternormalisasi adalah kandidat kunci kuat. Tanpa DOI, pencocokan judul/tahun/venue perlu rekonsiliasi.
- Relasi FK harus valid; pasangan author-publication dan urutan penulis tidak boleh duplikat.
- Kasus ambigu sebaiknya dikarantina/direkonsiliasi, bukan dihapus diam-diam.
- MART memilih snapshot metrik terbaru per publikasi dan sumber; angka antar sumber tidak otomatis sebanding.
- Perubahan skema perlu migration bernomor dan review; jangan mengubah migration yang sudah dipakai di environment bersama.
