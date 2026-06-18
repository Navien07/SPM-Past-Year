import { PrismaClient } from "@prisma/client";
import { hashPassword } from "../src/lib/password";

const prisma = new PrismaClient();

// ── Subject + topic taxonomy (KSSM, Form 4–5) ──────────────────────────────
const SUBJECTS: {
  name: string;
  nameEn: string;
  code: string;
  color: string;
  topics: { form: number; chapter: number; title: string; subtopics: string[] }[];
}[] = [
  {
    name: "Sejarah",
    nameEn: "History",
    code: "SEJ",
    color: "#b45309",
    topics: [
      // KSSM Sejarah Tingkatan 4 — Tema: Pembinaan Negara Bangsa
      { form: 4, chapter: 1, title: "Warisan Negara Bangsa", subtopics: ["Ciri negara bangsa", "Kesultanan Melayu Melaka", "Kedaulatan & jati diri"] },
      { form: 4, chapter: 2, title: "Kebangkitan Nasionalisme", subtopics: ["Maksud nasionalisme", "Faktor kemunculan", "Kesedaran kebangsaan"] },
      { form: 4, chapter: 3, title: "Nasionalisme di Malaysia Sehingga Perang Dunia Kedua", subtopics: ["Gerakan Islah", "Akhbar & majalah", "Persatuan Melayu"] },
      { form: 4, chapter: 4, title: "Konflik Dunia dan Pendudukan Jepun", subtopics: ["Perang Dunia Kedua", "Pendudukan Jepun", "Semangat anti-penjajah"] },
      { form: 4, chapter: 5, title: "Era Peralihan Kuasa British (Malayan Union 1946)", subtopics: ["Malayan Union", "Penentangan Melayu", "Penubuhan UMNO"] },
      { form: 4, chapter: 6, title: "Persekutuan Tanah Melayu 1948", subtopics: ["Perlembagaan 1948", "Kedudukan Raja-Raja Melayu", "Kerakyatan"] },
      { form: 4, chapter: 7, title: "Ancaman Komunis dan Perisytiharan Darurat", subtopics: ["Parti Komunis Malaya", "Darurat 1948", "Rancangan Briggs"] },
      { form: 4, chapter: 8, title: "Usaha ke Arah Kemerdekaan", subtopics: ["Sistem Ahli", "Pakatan Murni", "Pilihan Raya 1955"] },
      { form: 4, chapter: 9, title: "Perlembagaan Persekutuan Tanah Melayu 1957", subtopics: ["Suruhanjaya Reid", "Kontrak sosial", "Hak istimewa"] },
      { form: 4, chapter: 10, title: "Pemasyhuran Kemerdekaan", subtopics: ["31 Ogos 1957", "Peranan Tunku Abdul Rahman", "Makna kemerdekaan"] },
      // KSSM Sejarah Tingkatan 5 — Tema: Kedaulatan Negara
      { form: 5, chapter: 1, title: "Kedaulatan Negara", subtopics: ["Konsep kedaulatan", "Ciri negara berdaulat", "Mempertahankan kedaulatan"] },
      { form: 5, chapter: 2, title: "Perlembagaan Persekutuan", subtopics: ["Keluhuran perlembagaan", "Unsur tradisi", "Kebebasan asasi"] },
      { form: 5, chapter: 3, title: "Raja Berperlembagaan dan Demokrasi Berparlimen", subtopics: ["Yang di-Pertuan Agong", "Majlis Raja-Raja", "Pengasingan kuasa"] },
      { form: 5, chapter: 4, title: "Sistem Persekutuan", subtopics: ["Konsep persekutuan", "Pembahagian kuasa", "Senarai Persekutuan & Negeri"] },
      { form: 5, chapter: 5, title: "Pembentukan Malaysia", subtopics: ["Idea Malaysia", "Suruhanjaya Cobbold", "Perjanjian Malaysia 1963"] },
      { form: 5, chapter: 6, title: "Cabaran Selepas Pembentukan Malaysia", subtopics: ["Konfrontasi Indonesia", "Tuntutan Filipina", "Singapura keluar 1965"] },
      { form: 5, chapter: 7, title: "Membina Kesejahteraan Negara", subtopics: ["Peristiwa 13 Mei 1969", "MAGERAN", "Rukun Negara & DEB"] },
      { form: 5, chapter: 8, title: "Membina Kemakmuran Negara", subtopics: ["Dasar perindustrian", "Dasar pertanian", "Dasar pembangunan ekonomi"] },
      { form: 5, chapter: 9, title: "Dasar Luar Malaysia", subtopics: ["Prinsip dasar luar", "Dasar berkecuali", "ASEAN, NAM, OIC, PBB"] },
      { form: 5, chapter: 10, title: "Kecemerlangan Malaysia di Persada Dunia", subtopics: ["Tokoh & pencapaian", "Sumbangan global", "Wawasan masa depan"] },
    ],
  },
  {
    name: "Bahasa Melayu", nameEn: "Malay Language", code: "BM", color: "#dc2626",
    topics: [
      // KSSM BM — kemahiran bahasa (sama bagi Tingkatan 4 & 5; KOMSAS ikut tingkatan)
      { form: 4, chapter: 1, title: "Karangan", subtopics: ["Karangan respons terbuka", "Karangan berdasarkan bahan rangsangan"] },
      { form: 4, chapter: 2, title: "Pemahaman", subtopics: ["Petikan pemahaman", "Kosa kata", "Memproses maklumat"] },
      { form: 4, chapter: 3, title: "Rumusan", subtopics: ["Isi tersurat", "Isi tersirat"] },
      { form: 4, chapter: 4, title: "Tatabahasa", subtopics: ["Morfologi (bentuk kata)", "Sintaksis (frasa & ayat)"] },
      { form: 4, chapter: 5, title: "KOMSAS Tingkatan 4", subtopics: ["Antologi Jaket Kulit Kijang dari Istanbul", "Novel Leftenan Adnan Wira Bangsa"] },
      { form: 5, chapter: 1, title: "Karangan", subtopics: ["Karangan respons terbuka", "Karangan berdasarkan bahan rangsangan"] },
      { form: 5, chapter: 2, title: "Pemahaman & Rumusan", subtopics: ["Pemahaman petikan", "Rumusan"] },
      { form: 5, chapter: 3, title: "Tatabahasa", subtopics: ["Golongan kata", "Ayat", "Laras bahasa"] },
      { form: 5, chapter: 4, title: "KOMSAS Tingkatan 5", subtopics: ["Antologi Sejadah Rindu", "Novel Silir Daksina"] },
    ],
  },
  {
    name: "English", nameEn: "English", code: "ENG", color: "#2563eb",
    topics: [
      // KSSM English (CEFR-aligned) — skills across themes; Form 4 then Form 5
      { form: 4, chapter: 1, title: "Reading", subtopics: ["Skimming & scanning", "Inference", "People and Culture"] },
      { form: 4, chapter: 2, title: "Writing", subtopics: ["Emails & messages", "Reviews", "Short essays"] },
      { form: 4, chapter: 3, title: "Speaking & Listening", subtopics: ["Presentations", "Discussions", "Listening for gist"] },
      { form: 4, chapter: 4, title: "Grammar in Use", subtopics: ["Tenses", "Subject-verb agreement", "Connectors"] },
      { form: 4, chapter: 5, title: "Literature in Action", subtopics: ["Poems", "Short stories", "Drama"] },
      { form: 5, chapter: 1, title: "Reading", subtopics: ["Extended texts", "Critical reading", "Science and Technology"] },
      { form: 5, chapter: 2, title: "Writing", subtopics: ["Reports", "Argumentative essays", "Formal letters"] },
      { form: 5, chapter: 3, title: "Speaking & Listening", subtopics: ["Debates", "Interviews", "Note-taking"] },
      { form: 5, chapter: 4, title: "Grammar in Use", subtopics: ["Passive voice", "Conditionals", "Reported speech"] },
      { form: 5, chapter: 5, title: "Literature in Action", subtopics: ["Novel", "Poems", "Drama"] },
    ],
  },
  {
    name: "Mathematics", nameEn: "Mathematics", code: "MATE", color: "#059669",
    topics: [
      // KSSM Matematik Tingkatan 4 (10 bab)
      { form: 4, chapter: 1, title: "Fungsi dan Persamaan Kuadratik dalam Satu Pemboleh Ubah", subtopics: ["Fungsi kuadratik", "Punca persamaan", "Graf"] },
      { form: 4, chapter: 2, title: "Asas Nombor", subtopics: ["Nilai tempat", "Penukaran asas", "Operasi asas n"] },
      { form: 4, chapter: 3, title: "Penaakulan Logik", subtopics: ["Pernyataan", "Pengkuantiti & negasi", "Hujah deduktif/induktif"] },
      { form: 4, chapter: 4, title: "Operasi Set", subtopics: ["Persilangan", "Kesatuan", "Pelengkap set"] },
      { form: 4, chapter: 5, title: "Rangkaian dalam Teori Graf", subtopics: ["Bucu & tepi", "Graf berpemberat", "Aplikasi rangkaian"] },
      { form: 4, chapter: 6, title: "Ketaksamaan Linear dalam Dua Pemboleh Ubah", subtopics: ["Ketaksamaan linear", "Sistem ketaksamaan", "Rantau"] },
      { form: 4, chapter: 7, title: "Graf Gerakan", subtopics: ["Graf jarak-masa", "Graf laju-masa", "Tafsiran graf"] },
      { form: 4, chapter: 8, title: "Sukatan Serakan Data Tak Terkumpul", subtopics: ["Julat & julat antara kuartil", "Varians", "Sisihan piawai"] },
      { form: 4, chapter: 9, title: "Kebarangkalian Peristiwa Bergabung", subtopics: ["Peristiwa saling eksklusif", "Hukum tambah", "Hukum darab"] },
      { form: 4, chapter: 10, title: "Matematik Pengguna: Pengurusan Kewangan", subtopics: ["Belanjawan", "Aliran tunai", "Simpanan & pelaburan"] },
      // KSSM Matematik Tingkatan 5 (8 bab)
      { form: 5, chapter: 1, title: "Ubahan", subtopics: ["Ubahan langsung", "Ubahan songsang", "Ubahan tercantum"] },
      { form: 5, chapter: 2, title: "Matriks", subtopics: ["Operasi matriks", "Pendaraban matriks", "Matriks songsang"] },
      { form: 5, chapter: 3, title: "Matematik Pengguna: Insurans", subtopics: ["Konsep risiko", "Insurans nyawa & am", "Premium"] },
      { form: 5, chapter: 4, title: "Matematik Pengguna: Percukaian", subtopics: ["Cukai pendapatan", "Cukai jualan & perkhidmatan", "Pelepasan cukai"] },
      { form: 5, chapter: 5, title: "Kekongruenan, Pembesaran dan Gabungan Transformasi", subtopics: ["Kekongruenan", "Pembesaran", "Gabungan transformasi"] },
      { form: 5, chapter: 6, title: "Nisbah dan Graf Fungsi Trigonometri", subtopics: ["Nisbah trigonometri", "Sudut rujuk", "Graf sin, kos, tan"] },
      { form: 5, chapter: 7, title: "Sukatan Serakan Data Terkumpul", subtopics: ["Jadual kekerapan", "Histogram & ogif", "Varians & sisihan piawai"] },
      { form: 5, chapter: 8, title: "Pemodelan Matematik", subtopics: ["Proses pemodelan", "Pembentukan model", "Tafsiran model"] },
    ],
  },
  {
    name: "Additional Mathematics", nameEn: "Additional Mathematics", code: "ADDMATE", color: "#0d9488",
    topics: [
      // KSSM Matematik Tambahan Tingkatan 4 (10 bab)
      { form: 4, chapter: 1, title: "Fungsi", subtopics: ["Tatatanda fungsi", "Fungsi gubahan", "Fungsi songsang"] },
      { form: 4, chapter: 2, title: "Fungsi Kuadratik", subtopics: ["Persamaan & ketaksamaan kuadratik", "Diskriminan", "Graf"] },
      { form: 4, chapter: 3, title: "Sistem Persamaan", subtopics: ["Persamaan linear tiga pemboleh ubah", "Persamaan serentak"] },
      { form: 4, chapter: 4, title: "Indeks, Surd dan Logaritma", subtopics: ["Hukum indeks", "Hukum surd", "Hukum logaritma"] },
      { form: 4, chapter: 5, title: "Janjang", subtopics: ["Janjang aritmetik", "Janjang geometri", "Hasil tambah hingga ketakterhinggaan"] },
      { form: 4, chapter: 6, title: "Hukum Linear", subtopics: ["Garis lurus penyuaian terbaik", "Bentuk tak linear ke linear"] },
      { form: 4, chapter: 7, title: "Geometri Koordinat", subtopics: ["Pembahagi tembereng garis", "Luas poligon", "Lokus"] },
      { form: 4, chapter: 8, title: "Vektor", subtopics: ["Vektor & skalar", "Vektor satah Cartesan", "Operasi vektor"] },
      { form: 4, chapter: 9, title: "Penyelesaian Segi Tiga", subtopics: ["Petua sinus", "Petua kosinus", "Luas segi tiga"] },
      { form: 4, chapter: 10, title: "Nombor Indeks", subtopics: ["Nombor indeks", "Indeks gubahan"] },
      // KSSM Matematik Tambahan Tingkatan 5 (8 bab)
      { form: 5, chapter: 1, title: "Sukatan Membulat", subtopics: ["Radian", "Panjang lengkok", "Luas sektor"] },
      { form: 5, chapter: 2, title: "Pembezaan", subtopics: ["Terbitan pertama", "Terbitan kedua", "Kadar perubahan & maksimum-minimum"] },
      { form: 5, chapter: 3, title: "Pengamiran", subtopics: ["Kamiran tak tentu", "Kamiran tentu", "Luas & isi padu kisaran"] },
      { form: 5, chapter: 4, title: "Pilih Atur dan Gabungan", subtopics: ["Prinsip pendaraban", "Permutasi (nPr)", "Kombinasi (nCr)"] },
      { form: 5, chapter: 5, title: "Taburan Kebarangkalian", subtopics: ["Pemboleh ubah rawak", "Taburan binomial", "Taburan normal"] },
      { form: 5, chapter: 6, title: "Fungsi Trigonometri", subtopics: ["Fungsi sebarang sudut", "Identiti trigonometri", "Rumus sudut majmuk"] },
      { form: 5, chapter: 7, title: "Pengaturcaraan Linear", subtopics: ["Model ketaksamaan linear", "Rantau", "Nilai optimum"] },
      { form: 5, chapter: 8, title: "Kinematik Gerakan Linear", subtopics: ["Sesaran", "Halaju", "Pecutan"] },
    ],
  },
  {
    name: "Physics", nameEn: "Physics", code: "FIZ", color: "#7c3aed",
    topics: [
      // KSSM Fizik Tingkatan 4 (6 bab)
      { form: 4, chapter: 1, title: "Pengukuran", subtopics: ["Kuantiti fizik & unit", "Ralat & ketidakpastian", "Ketepatan & kejituan"] },
      { form: 4, chapter: 2, title: "Daya dan Gerakan I", subtopics: ["Gerakan linear", "Hukum Newton & momentum", "Daya geseran"] },
      { form: 4, chapter: 3, title: "Kegravitian", subtopics: ["Hukum kegravitian Newton", "Pecutan graviti", "Satelit & orbit"] },
      { form: 4, chapter: 4, title: "Haba", subtopics: ["Keseimbangan terma", "Muatan haba tentu", "Haba pendam tentu"] },
      { form: 4, chapter: 5, title: "Gelombang", subtopics: ["Gelombang melintang & membujur", "Pantulan & pembiasan", "Gelombang elektromagnet"] },
      { form: 4, chapter: 6, title: "Cahaya dan Optik", subtopics: ["Pembiasan cahaya", "Pantulan dalam penuh", "Kanta nipis & alat optik"] },
      // KSSM Fizik Tingkatan 5 (7 bab)
      { form: 5, chapter: 1, title: "Daya dan Gerakan II", subtopics: ["Gerakan dua matra", "Hentaman & keanjalan", "Gerakan projektil"] },
      { form: 5, chapter: 2, title: "Tekanan", subtopics: ["Tekanan cecair & atmosfera", "Prinsip Pascal", "Prinsip Archimedes & Bernoulli"] },
      { form: 5, chapter: 3, title: "Keelektrikan", subtopics: ["Hukum Ohm", "Tenaga & kuasa elektrik", "D.g.e. & rintangan dalam"] },
      { form: 5, chapter: 4, title: "Keelektromagnetan", subtopics: ["Daya pada konduktor", "Aruhan elektromagnet", "Transformer"] },
      { form: 5, chapter: 5, title: "Elektronik", subtopics: ["Sinar katod (osiloskop)", "Diod & rektifikasi", "Transistor"] },
      { form: 5, chapter: 6, title: "Fizik Nuklear", subtopics: ["Kereputan radioaktif", "Tenaga nuklear (E=mc²)", "Pembelahan & pelakuran"] },
      { form: 5, chapter: 7, title: "Fizik Kuantum", subtopics: ["Zarah gelombang", "Kesan fotoelektrik", "Aplikasi fotoelektrik"] },
    ],
  },
  {
    name: "Chemistry", nameEn: "Chemistry", code: "KIM", color: "#db2777",
    topics: [
      // KSSM Kimia Tingkatan 4 (8 bab)
      { form: 4, chapter: 1, title: "Pengenalan kepada Kimia", subtopics: ["Bidang & kerjaya kimia", "Kaedah saintifik", "Pengurusan bahan kimia"] },
      { form: 4, chapter: 2, title: "Jirim dan Struktur Atom", subtopics: ["Teori kinetik jirim", "Model atom", "Isotop"] },
      { form: 4, chapter: 3, title: "Konsep Mol, Formula dan Persamaan Kimia", subtopics: ["Jisim atom relatif", "Konsep mol", "Formula empirik & molekul"] },
      { form: 4, chapter: 4, title: "Jadual Berkala Unsur", subtopics: ["Jadual berkala moden", "Unsur Kumpulan 1, 17, 18", "Unsur peralihan"] },
      { form: 4, chapter: 5, title: "Ikatan Kimia", subtopics: ["Ikatan ion", "Ikatan kovalen", "Sifat sebatian"] },
      { form: 4, chapter: 6, title: "Asid, Bes dan Garam", subtopics: ["pH", "Peneutralan", "Penyediaan garam"] },
      { form: 4, chapter: 7, title: "Kadar Tindak Balas", subtopics: ["Faktor mempengaruhi kadar", "Mangkin", "Teori perlanggaran"] },
      { form: 4, chapter: 8, title: "Bahan Buatan dalam Industri", subtopics: ["Aloi", "Kaca & seramik", "Bahan komposit"] },
      // KSSM Kimia Tingkatan 5 (5 bab)
      { form: 5, chapter: 1, title: "Keseimbangan Redoks", subtopics: ["Pengoksidaan & penurunan", "Sel kimia & elektrolisis", "Pengaratan"] },
      { form: 5, chapter: 2, title: "Sebatian Karbon", subtopics: ["Hidrokarbon (alkana, alkena)", "Alkohol & asid karboksilik", "Ester & lemak"] },
      { form: 5, chapter: 3, title: "Termokimia", subtopics: ["Tindak balas eksotermik & endotermik", "Haba peneutralan", "Haba pembakaran"] },
      { form: 5, chapter: 4, title: "Polimer", subtopics: ["Pempolimeran", "Getah asli", "Getah sintetik"] },
      { form: 5, chapter: 5, title: "Kimia Konsumer dan Industri", subtopics: ["Minyak & lemak", "Sabun & detergen", "Bahan tambah makanan"] },
    ],
  },
  {
    name: "Biology", nameEn: "Biology", code: "BIO", color: "#16a34a",
    topics: [
      // KSSM Biologi Tingkatan 4 (7 bab)
      { form: 4, chapter: 1, title: "Pengenalan kepada Biologi dan Peraturan Makmal", subtopics: ["Bidang & kerjaya biologi", "Keselamatan makmal", "Pengendalian radas"] },
      { form: 4, chapter: 2, title: "Biologi Sel dan Organisasi Sel", subtopics: ["Struktur & fungsi sel", "Organisasi sel", "Sel khusus"] },
      { form: 4, chapter: 3, title: "Pergerakan Bahan Merentas Membran Plasma", subtopics: ["Resapan", "Osmosis", "Pengangkutan aktif"] },
      { form: 4, chapter: 4, title: "Komposisi Kimia dalam Sel", subtopics: ["Karbohidrat & protein", "Lipid", "Asid nukleik"] },
      { form: 4, chapter: 5, title: "Metabolisme dan Enzim", subtopics: ["Anabolisme & katabolisme", "Tindakan enzim", "Faktor mempengaruhi enzim"] },
      { form: 4, chapter: 6, title: "Pembahagian Sel", subtopics: ["Kitaran sel & mitosis", "Meiosis", "Kepentingan pembahagian sel"] },
      { form: 4, chapter: 7, title: "Respirasi Sel", subtopics: ["Respirasi aerob", "Respirasi anaerob", "Tenaga & ATP"] },
      // KSSM Biologi Tingkatan 5 (13 bab)
      { form: 5, chapter: 1, title: "Organisasi Tisu Tumbuhan dan Pertumbuhan", subtopics: ["Meristem", "Tisu tumbuhan", "Pertumbuhan primer & sekunder"] },
      { form: 5, chapter: 2, title: "Struktur dan Fungsi Daun", subtopics: ["Struktur daun", "Fotosintesis", "Faktor mempengaruhi fotosintesis"] },
      { form: 5, chapter: 3, title: "Nutrisi dalam Tumbuhan", subtopics: ["Nutrien mineral", "Pengambilan nutrien", "Kepentingan nutrien"] },
      { form: 5, chapter: 4, title: "Pengangkutan dalam Tumbuhan", subtopics: ["Xilem & transpirasi", "Floem & translokasi"] },
      { form: 5, chapter: 5, title: "Gerak Balas dalam Tumbuhan", subtopics: ["Tropisme", "Hormon tumbuhan (auksin)", "Aplikasi hormon"] },
      { form: 5, chapter: 6, title: "Pembiakan Seks dalam Tumbuhan Berbunga", subtopics: ["Struktur bunga", "Pendebungaan & persenyawaan", "Perkembangan biji & buah"] },
      { form: 5, chapter: 7, title: "Penyesuaian Tumbuhan pada Habitat", subtopics: ["Hidrofit", "Xerofit", "Halofit & mesofit"] },
      { form: 5, chapter: 8, title: "Biodiversiti", subtopics: ["Kepelbagaian hidupan", "Pengelasan organisma", "Kepentingan biodiversiti"] },
      { form: 5, chapter: 9, title: "Ekosistem", subtopics: ["Komponen ekosistem", "Aliran tenaga & siratan makanan", "Kitar nutrien"] },
      { form: 5, chapter: 10, title: "Kelestarian Alam Sekitar", subtopics: ["Pencemaran", "Kesan aktiviti manusia", "Pemuliharaan & pemeliharaan"] },
      { form: 5, chapter: 11, title: "Pewarisan", subtopics: ["Hukum Mendel", "Kacukan monohibrid & dihibrid", "Penyakit genetik"] },
      { form: 5, chapter: 12, title: "Variasi", subtopics: ["Variasi selanjar & tak selanjar", "Faktor genetik & persekitaran", "Mutasi"] },
      { form: 5, chapter: 13, title: "Kejuruteraan Genetik dan Bioteknologi", subtopics: ["DNA rekombinan", "Aplikasi bioteknologi", "Implikasi etika"] },
    ],
  },
  {
    name: "Pendidikan Islam", nameEn: "Islamic Studies", code: "PI", color: "#0f766e",
    topics: [
      // KSSM Pendidikan Islam — disusun ikut bidang
      { form: 4, chapter: 1, title: "Al-Quran (Tilawah)", subtopics: ["Surah al-An'am & al-Kahfi", "Hukum tajwid", "Larangan rasuah"] },
      { form: 4, chapter: 2, title: "Hadis", subtopics: ["Hindari dosa besar", "Kemuliaan berdikari"] },
      { form: 4, chapter: 3, title: "Akidah", subtopics: ["Al-Asma' al-Husna", "Perkara membatalkan iman", "Hindari ajaran sesat"] },
      { form: 4, chapter: 4, title: "Ibadah (Fiqah)", subtopics: ["Haji & umrah", "Sembelihan, korban & akikah", "Muamalat Islam"] },
      { form: 4, chapter: 5, title: "Sirah dan Tamadun Islam", subtopics: ["Khulafa ar-Rasyidin", "Kerajaan Umaiyah & Abbasiyah", "Tokoh empat mazhab"] },
      { form: 4, chapter: 6, title: "Akhlak Islamiah", subtopics: ["Benar & jauhi munafik", "Khauf & raja'", "Wasatiah"] },
      { form: 5, chapter: 1, title: "Al-Quran (Tilawah)", subtopics: ["Surah at-Taubah & al-Hasyr", "Tajwid: Ra, wakaf & ibtida'", "Ciri mukmin berjaya"] },
      { form: 5, chapter: 2, title: "Hadis", subtopics: ["Setiap orang pemimpin", "Tujuh golongan dapat naungan Allah"] },
      { form: 5, chapter: 3, title: "Akidah", subtopics: ["Allah Maha Mengawasi", "Akidah Ahli Sunnah Waljamaah"] },
      { form: 5, chapter: 4, title: "Ibadah (Fiqah)", subtopics: ["Perkahwinan & isu-isunya", "Pengurusan harta & faraid", "Jenayah dalam Islam"] },
      { form: 5, chapter: 5, title: "Sirah dan Tamadun Islam", subtopics: ["Kerajaan Uthmaniyah", "Keunggulan tokoh Islam"] },
      { form: 5, chapter: 6, title: "Akhlak Islamiah", subtopics: ["Tawaduk", "Istiqamah & mujahadah", "Sifat mazmumah"] },
    ],
  },
  {
    name: "Pendidikan Moral", nameEn: "Moral Education", code: "PM", color: "#9333ea",
    topics: [
      // KSSM Pendidikan Moral — Tingkatan 4 & 5 meliputi Bidang 5, 6, 7 (18 nilai universal)
      { form: 4, chapter: 1, title: "Insan Bermoral (Bidang 5)", subtopics: ["Norma masyarakat", "Peribadi mulia", "Keadilan dalam membuat keputusan", "Etika penggunaan ICT"] },
      { form: 4, chapter: 2, title: "Jati Diri Moral (Bidang 6)", subtopics: ["Integriti & jati diri", "Keluarga berintegriti", "Perikemanusiaan"] },
      { form: 4, chapter: 3, title: "Moral dan Kenegaraan (Bidang 7)", subtopics: ["Hak & tanggungjawab warganegara", "Perpaduan", "Keunikan rakyat Malaysia", "Kedaulatan negara"] },
      { form: 5, chapter: 1, title: "Insan Bermoral (Bidang 5)", subtopics: ["Norma masyarakat global", "Akauntabiliti", "Jati diri di mata dunia", "Kerohanian"] },
      { form: 5, chapter: 2, title: "Jati Diri Moral (Bidang 6)", subtopics: ["Integriti organisasi", "Keluarga", "Pembangunan negara berintegriti"] },
      { form: 5, chapter: 3, title: "Moral dan Kenegaraan (Bidang 7)", subtopics: ["Penglibatan komuniti", "Kerjasama masyarakat global", "Pengurusan kewangan beretika", "Hubungan antarabangsa"] },
    ],
  },
  {
    name: "Ekonomi", nameEn: "Economics", code: "EKO", color: "#ca8a04",
    topics: [
      // KSSM Ekonomi Tingkatan 4 (4 bab)
      { form: 4, chapter: 1, title: "Pengenalan kepada Ekonomi", subtopics: ["Masalah asas ekonomi", "Kos lepas & KKP", "Sistem ekonomi"] },
      { form: 4, chapter: 2, title: "Pasaran", subtopics: ["Permintaan & penawaran", "Keseimbangan pasaran", "Keanjalan"] },
      { form: 4, chapter: 3, title: "Wang, Bank dan Pendapatan Individu", subtopics: ["Fungsi wang", "Sistem perbankan", "Pendapatan individu"] },
      { form: 4, chapter: 4, title: "Pengeluaran", subtopics: ["Faktor pengeluaran", "Jenis pasaran", "Kos & hasil"] },
      // KSSM Ekonomi Tingkatan 5 (2 bab)
      { form: 5, chapter: 1, title: "Ekonomi dan Kerajaan", subtopics: ["Dasar fiskal & belanjawan", "Dasar kewangan", "Guna tenaga & inflasi"] },
      { form: 5, chapter: 2, title: "Malaysia dan Ekonomi Global", subtopics: ["Globalisasi & FDI", "Perdagangan antarabangsa", "Imbangan pembayaran & kadar pertukaran"] },
    ],
  },
  {
    name: "Prinsip Perakaunan", nameEn: "Principles of Accounting", code: "PP", color: "#0891b2",
    topics: [
      // KSSM Prinsip Perakaunan Tingkatan 4 (9 bab)
      { form: 4, chapter: 1, title: "Pengenalan kepada Perakaunan", subtopics: ["Perakaunan vs simpan kira", "Profesion perakaunan", "Prinsip & andaian"] },
      { form: 4, chapter: 2, title: "Klasifikasi Akaun dan Persamaan Perakaunan", subtopics: ["Aset, liabiliti, ekuiti", "Persamaan perakaunan", "Kesan urus niaga"] },
      { form: 4, chapter: 3, title: "Dokumen Perakaunan sebagai Sumber Maklumat", subtopics: ["Invois & nota debit/kredit", "Resit & baucar", "Penggunaan dokumen"] },
      { form: 4, chapter: 4, title: "Buku Catatan Pertama", subtopics: ["Jurnal am & khas", "Buku tunai"] },
      { form: 4, chapter: 5, title: "Lejar", subtopics: ["Akaun T", "Pengeposan", "Pengimbangan akaun"] },
      { form: 4, chapter: 6, title: "Imbangan Duga", subtopics: ["Penyediaan imbangan duga", "Fungsi", "Kesilapan tidak menjejaskan"] },
      { form: 4, chapter: 7, title: "Penyata Kewangan Milikan Tunggal tanpa Pelarasan", subtopics: ["Penyata pendapatan", "Penyata kedudukan kewangan"] },
      { form: 4, chapter: 8, title: "Pelarasan dan Penyata Kewangan Milikan Tunggal", subtopics: ["Belanja/hasil terakru & terdahulu", "Susut nilai", "Hutang lapuk & peruntukan"] },
      { form: 4, chapter: 9, title: "Pembetulan Kesilapan", subtopics: ["Jenis kesilapan", "Jurnal pembetulan", "Akaun penggantungan"] },
      // KSSM Prinsip Perakaunan Tingkatan 5 (7 bab)
      { form: 5, chapter: 1, title: "Analisis dan Tafsiran Penyata Kewangan", subtopics: ["Nisbah keberuntungan", "Nisbah kecairan", "Tafsiran prestasi"] },
      { form: 5, chapter: 2, title: "Rekod Tak Lengkap", subtopics: ["Untung/rugi daripada perubahan ekuiti", "Kaedah analisis", "Penyata kewangan"] },
      { form: 5, chapter: 3, title: "Perakaunan untuk Kawalan Dalaman", subtopics: ["Kawalan tunai", "Penyata penyesuaian bank", "Belanjawan tunai"] },
      { form: 5, chapter: 4, title: "Perakaunan untuk Perkongsian", subtopics: ["Akaun modal & semasa", "Perjanjian perkongsian", "Agihan untung rugi"] },
      { form: 5, chapter: 5, title: "Perakaunan untuk Syarikat Berhad menurut Syer", subtopics: ["Jenis & terbitan syer", "Debentur", "Penyata kewangan syarikat"] },
      { form: 5, chapter: 6, title: "Perakaunan untuk Kelab dan Persatuan", subtopics: ["Akaun penerimaan & pembayaran", "Akaun yuran ahli", "Akaun pendapatan & perbelanjaan"] },
      { form: 5, chapter: 7, title: "Perakaunan Kos", subtopics: ["Kos pengeluaran", "Penyata kos pengeluaran", "Klasifikasi kos"] },
    ],
  },
];

const SEJ_RUBRIC = JSON.stringify({
  criteria: [
    { name: "Pengenalan", maxMarks: 2, descriptor: "Latar belakang & konteks" },
    { name: "Isi / Fakta", maxMarks: 12, descriptor: "Fakta tepat dengan huraian" },
    { name: "Penerapan nilai / iktibar", maxMarks: 4, descriptor: "Nilai & iktibar relevan" },
    { name: "Kesimpulan", maxMarks: 2, descriptor: "Rumusan padat" },
  ],
});

type QSpec = {
  subject: string;
  topicTitle: string;
  paperNumber: number;
  type: "mcq" | "structured" | "essay";
  number?: string;
  stem: string;
  options?: { key: string; text: string }[];
  answer?: string;
  markingScheme?: string;
  rubric?: string;
  marks: number;
  kbat: boolean;
  subtopic?: string;
  year: number;
};

// Original, SPM-style sample questions (approved content for the student bank).
const APPROVED: QSpec[] = [
  { subject: "Sejarah", topicTitle: "Warisan Negara Bangsa", paperNumber: 1, type: "mcq", number: "1",
    stem: "Antara berikut, yang manakah merupakan ciri utama sebuah negara bangsa?",
    options: [{ key: "A", text: "Mempunyai wilayah dan sempadan yang jelas" }, { key: "B", text: "Tidak memerlukan kerajaan" }, { key: "C", text: "Tiada perlembagaan" }, { key: "D", text: "Rakyat daripada pelbagai negara" }],
    answer: "A", marks: 1, kbat: false, subtopic: "Ciri negara bangsa", year: 2025 },
  { subject: "Sejarah", topicTitle: "Era Peralihan Kuasa British (Malayan Union 1946)", paperNumber: 1, type: "mcq", number: "2",
    stem: "Mengapakah orang Melayu menentang penubuhan Malayan Union?",
    options: [{ key: "A", text: "Menghapuskan kedaulatan Raja-Raja Melayu" }, { key: "B", text: "Menambah kuasa Sultan" }, { key: "C", text: "Memperluas hak istimewa Melayu" }, { key: "D", text: "Menyatukan Tanah Melayu dengan Indonesia" }],
    answer: "A", marks: 1, kbat: true, subtopic: "Penentangan Melayu", year: 2025 },
  { subject: "Sejarah", topicTitle: "Usaha ke Arah Kemerdekaan", paperNumber: 2, type: "structured", number: "1(a)",
    stem: "Nyatakan dua usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu.",
    answer: "Pakatan Murni antara kaum; Sistem Ahli; Pilihan Raya Umum 1955; Rombongan ke London 1956.",
    markingScheme: "1 markah setiap usaha (maks 2).", marks: 2, kbat: false, subtopic: "Pakatan Murni", year: 2025 },
  { subject: "Sejarah", topicTitle: "Usaha ke Arah Kemerdekaan", paperNumber: 2, type: "essay", number: "5",
    stem: "Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.",
    markingScheme: "Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.",
    rubric: SEJ_RUBRIC, marks: 20, kbat: true, subtopic: "Pilihan Raya 1955", year: 2025 },

  { subject: "Mathematics", topicTitle: "Fungsi dan Persamaan Kuadratik dalam Satu Pemboleh Ubah", paperNumber: 2, type: "structured",
    stem: "The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.",
    answer: "b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.", markingScheme: "Discriminant = 0 (1m); substitute (1m); k = 9 (1m).",
    marks: 3, kbat: false, year: 2024 },
  { subject: "Mathematics", topicTitle: "Kebarangkalian Peristiwa Bergabung", paperNumber: 1, type: "mcq",
    stem: "A fair die is rolled once. What is the probability of getting a number greater than 4?",
    options: [{ key: "A", text: "1/6" }, { key: "B", text: "1/3" }, { key: "C", text: "1/2" }, { key: "D", text: "2/3" }],
    answer: "B", marks: 1, kbat: false, year: 2024 },

  { subject: "Additional Mathematics", topicTitle: "Pembezaan", paperNumber: 1, type: "structured",
    stem: "Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.",
    answer: "dy/dx = 6x − 5; at x = 2, gradient = 7.", markingScheme: "Differentiate (1m); substitute (1m); answer (1m).",
    marks: 3, kbat: false, year: 2024 },

  { subject: "Physics", topicTitle: "Daya dan Gerakan I", paperNumber: 1, type: "mcq",
    stem: "A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?",
    options: [{ key: "A", text: "500 N" }, { key: "B", text: "1000 N" }, { key: "C", text: "2000 N" }, { key: "D", text: "4000 N" }],
    answer: "C", marks: 1, kbat: false, year: 2024 },
  // Science Paper 3 (practical / amali) example
  { subject: "Physics", topicTitle: "Haba", paperNumber: 3, type: "structured",
    stem: "An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.",
    answer: "Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.",
    markingScheme: "1 markah setiap pemboleh ubah (maks 3).", marks: 3, kbat: true, year: 2024 },

  { subject: "Chemistry", topicTitle: "Asid, Bes dan Garam", paperNumber: 2, type: "structured",
    stem: "Explain why a solution of ammonia in water is alkaline.",
    answer: "Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.",
    markingScheme: "OH⁻ ions present (1m); reaction with water (1m).", marks: 2, kbat: true, year: 2023 },
  { subject: "Chemistry", topicTitle: "Asid, Bes dan Garam", paperNumber: 3, type: "structured",
    stem: "In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.",
    answer: "Pink to colourless.", markingScheme: "Correct colour change (1m).", marks: 1, kbat: false, year: 2023 },

  { subject: "Biology", topicTitle: "Struktur dan Fungsi Daun", paperNumber: 2, type: "essay",
    stem: "Describe the process of photosynthesis and explain its importance to living organisms.",
    markingScheme: "Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.",
    marks: 10, kbat: true, year: 2024 },
  { subject: "Biology", topicTitle: "Biologi Sel dan Organisasi Sel", paperNumber: 1, type: "mcq",
    stem: "Which structure controls the movement of substances into and out of a cell?",
    options: [{ key: "A", text: "Cell wall" }, { key: "B", text: "Plasma membrane" }, { key: "C", text: "Nucleus" }, { key: "D", text: "Vacuole" }],
    answer: "B", marks: 1, kbat: false, year: 2024 },

  { subject: "English", topicTitle: "Writing", paperNumber: 1, type: "essay",
    stem: "Write a story that ends with: '…and that was the day I learned the true meaning of courage.'",
    markingScheme: "Assess language, content relevance and organisation.", marks: 30, kbat: false, year: 2024 },
  { subject: "Bahasa Melayu", topicTitle: "Karangan", paperNumber: 1, type: "essay",
    stem: "Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.",
    markingScheme: "Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.", marks: 35, kbat: false, year: 2023 },
];

// Papers the admin "uploaded" whose AI categorization is awaiting the moderator.
const PENDING_PAPERS: {
  title: string; subject: string; paperType: string; year: number; state?: string; paperNumber: number;
  questions: QSpec[];
}[] = [
  {
    title: "Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)",
    subject: "Additional Mathematics", paperType: "trial", year: 2025, state: "Johor", paperNumber: 1,
    questions: [
      { subject: "Additional Mathematics", topicTitle: "Fungsi", paperNumber: 1, type: "structured", number: "1",
        stem: "Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).",
        answer: "fg(x) = 2x² + 3; gf(x) = (2x + 3)².", markingScheme: "Each composite (1m).", marks: 2, kbat: false, year: 2025 },
      { subject: "Additional Mathematics", topicTitle: "Pilih Atur dan Gabungan", paperNumber: 1, type: "structured", number: "2",
        stem: "In how many ways can 5 different books be arranged on a shelf?",
        answer: "5! = 120.", markingScheme: "5! (1m); 120 (1m).", marks: 2, kbat: false, year: 2025 },
      { subject: "Additional Mathematics", topicTitle: "Pengamiran", paperNumber: 1, type: "structured", number: "3",
        stem: "Find ∫(6x² − 4x) dx.", answer: "2x³ − 2x² + c.", markingScheme: "Each term (1m); +c (1m).", marks: 2, kbat: true, year: 2025 },
    ],
  },
  {
    title: "Biology Kertas 2 — Percubaan SPM 2024 (Kedah)",
    subject: "Biology", paperType: "trial", year: 2024, state: "Kedah", paperNumber: 2,
    questions: [
      { subject: "Biology", topicTitle: "Biologi Sel dan Organisasi Sel", paperNumber: 2, type: "structured", number: "1",
        stem: "Explain how the structure of a red blood cell is adapted to its function.",
        answer: "Biconcave shape → large surface area; no nucleus → more space for haemoglobin.",
        markingScheme: "Each adaptation + reason (1m).", marks: 4, kbat: true, year: 2024 },
      { subject: "Biology", topicTitle: "Pewarisan", paperNumber: 2, type: "structured", number: "2",
        stem: "In a monohybrid cross between two heterozygous tall pea plants (Tt × Tt), state the expected genotypic and phenotypic ratios of the offspring.",
        answer: "Genotypic ratio 1 TT : 2 Tt : 1 tt; phenotypic ratio 3 tall : 1 short.",
        markingScheme: "Genotypic ratio (1m); phenotypic ratio (1m); correct reasoning (1m).", marks: 3, kbat: false, year: 2024 },
    ],
  },
];

async function main() {
  console.log("Seeding SPM AI LMS (roles + moderation)…");

  const subjectByName = new Map<string, string>();
  const subjectCodeByName = new Map<string, string>();
  const topicByKey = new Map<string, string>();

  for (const s of SUBJECTS) {
    const subject = await prisma.subject.upsert({
      where: { code: s.code },
      update: { name: s.name, nameEn: s.nameEn, color: s.color },
      create: { name: s.name, nameEn: s.nameEn, code: s.code, color: s.color },
    });
    subjectByName.set(s.name, subject.id);
    subjectCodeByName.set(s.name, s.code);
    for (const t of s.topics) {
      const topic = await prisma.topic.upsert({
        where: { subjectId_form_chapter: { subjectId: subject.id, form: t.form, chapter: t.chapter } },
        update: { title: t.title, subtopics: JSON.stringify(t.subtopics) },
        create: { subjectId: subject.id, form: t.form, chapter: t.chapter, title: t.title, subtopics: JSON.stringify(t.subtopics) },
      });
      topicByKey.set(`${s.name}::${t.title}`, topic.id);
    }
  }

  async function createQuestion(q: QSpec, paperId: string | null, status: string, confidence: number) {
    const subjectId = subjectByName.get(q.subject)!;
    const topicId = topicByKey.get(`${q.subject}::${q.topicTitle}`) ?? null;
    return prisma.question.create({
      data: {
        subjectId, topicId, paperId, paperNumber: q.paperNumber, questionType: q.type,
        number: q.number ?? null, stem: q.stem, options: JSON.stringify(q.options ?? []),
        answer: q.answer ?? null, markingScheme: q.markingScheme ?? null, rubric: q.rubric ?? null,
        marks: q.marks, isKbat: q.kbat, subtopic: q.subtopic ?? null, year: q.year, source: "past_paper",
        status, confidence, autoApproved: false,
        reviewNote: status === "approved" ? "Curated seed content" : null,
        reviewedAt: status === "approved" ? new Date() : null,
      },
    });
  }

  // Approved bank (high confidence / curated)
  const approvedQ: { id: string; subjectId: string }[] = [];
  for (const q of APPROVED) {
    const created = await createQuestion(q, null, "approved", 0.96);
    approvedQ.push({ id: created.id, subjectId: created.subjectId });
  }

  // Pending papers (low/mid AI confidence → flagged for moderation)
  for (const p of PENDING_PAPERS) {
    const subjectId = subjectByName.get(p.subject)!;
    const paper = await prisma.paper.create({
      data: { title: p.title, subjectId, paperType: p.paperType, year: p.year, state: p.state ?? null,
        paperNumber: p.paperNumber, status: "categorized", categorizedAt: new Date(),
        rawText: "Uploaded by admin; AI-categorized; awaiting moderation." },
    });
    let i = 0;
    for (const q of p.questions) {
      // Vary confidence so the moderator queue surfaces the doubtful ones first.
      const conf = [0.55, 0.68, 0.78, 0.62][i % 4];
      await createQuestion(q, paper.id, "pending", conf);
      i++;
    }
  }

  // Knowledge base ("main brain") — original, generic study notes that ground
  // Cikgu AI chat. Replace/extend with the school's own materials via /admin/knowledge.
  const KNOWLEDGE: { title: string; subject: string; form: number; kind: string; content: string }[] = [
    {
      title: "Photosynthesis — key concepts", subject: "Biology", form: 4, kind: "summary",
      content: "Photosynthesis is how green plants make food using light energy. It needs carbon dioxide, water, light and chlorophyll. The light-dependent reactions in the thylakoids capture light energy; the light-independent reactions (Calvin cycle) in the stroma fix carbon dioxide into glucose. Products are glucose and oxygen. It matters because it provides food (glucose) for almost all food chains and releases the oxygen animals breathe. Common SPM points: word equation, limiting factors (light intensity, CO2 concentration, temperature), and adaptations of the leaf (broad lamina, many chloroplasts, stomata).",
    },
    {
      title: "Acids, bases & salts — essentials", subject: "Chemistry", form: 4, kind: "summary",
      content: "An acid produces hydrogen ions (H+) in water; an alkali produces hydroxide ions (OH-). The pH scale runs 0–14: below 7 acidic, 7 neutral, above 7 alkaline. Neutralisation: acid + base produces salt + water. Salts can be prepared by reacting an acid with a metal, a base, or a carbonate. Titration uses an indicator (e.g. phenolphthalein turns pink in alkali, colourless in acid) to find the end point. Remember to balance equations and state observations.",
    },
    {
      title: "Pembinaan Negara dan Bangsa — Kemerdekaan 1957", subject: "Sejarah", form: 5, kind: "note",
      content: "Kemerdekaan Persekutuan Tanah Melayu dicapai melalui semangat perpaduan dan rundingan. Antara usaha penting: Pakatan Murni antara kaum, Pilihan Raya Umum 1955, rombongan ke London 1956, dan penubuhan Suruhanjaya Reid untuk merangka Perlembagaan. Iktibar: perpaduan kaum, semangat patriotik, toleransi, dan kepimpinan yang bijaksana penting untuk mengekalkan kemerdekaan dan kedaulatan negara.",
    },
  ];
  for (const k of KNOWLEDGE) {
    await prisma.knowledgeDoc.create({
      data: { title: k.title, subjectId: subjectByName.get(k.subject) ?? null, form: k.form, kind: k.kind, source: "Seed (sample notes)", content: k.content },
    });
  }

  // ── Users (admin handles review + everything; plus students) ─────────────
  await prisma.user.upsert({
    where: { email: "admin@spm.my" },
    update: { password: hashPassword("Admin123@"), role: "admin", name: "Admin Cikgu" },
    create: { email: "admin@spm.my", name: "Admin Cikgu", role: "admin", password: hashPassword("Admin123@") },
  });

  const STUDENTS: { name: string; email: string; form: number; subjects: string[]; password?: string; whatsapp?: string }[] = [
    // First pilot user.
    { name: "Vikhash", email: "vikhash@student.spm.my", form: 5, password: "Vikhash123@", whatsapp: "+60123456789",
      subjects: ["Sejarah", "Bahasa Melayu", "English", "Mathematics", "Additional Mathematics", "Physics", "Chemistry", "Biology"] },
    { name: "Ahmad", email: "ahmad@student.spm.my", form: 5, subjects: ["Sejarah", "Mathematics", "Physics", "Chemistry", "Biology", "Bahasa Melayu", "English"] },
    { name: "Siti Nurhaliza", email: "siti@student.spm.my", form: 5, subjects: ["Sejarah", "Bahasa Melayu", "English", "Mathematics", "Additional Mathematics", "Physics"] },
    { name: "Kumar Raj", email: "kumar@student.spm.my", form: 4, subjects: ["Mathematics", "Additional Mathematics", "Physics", "Chemistry"] },
    { name: "Mei Ling", email: "meiling@student.spm.my", form: 5, subjects: ["Sejarah", "Bahasa Melayu", "English", "Biology", "Chemistry"] },
  ];

  const PLANS = [
    { description: "Monthly Premium — Jun 2026", amount: 99, method: "fpx", status: "paid" },
    { description: "Monthly Premium — May 2026", amount: 99, method: "card", status: "paid" },
    { description: "Annual Plan 2026", amount: 899, method: "fpx", status: "paid" },
    { description: "Monthly Premium — Jun 2026", amount: 99, method: "ewallet", status: "pending" },
  ];

  const now = Date.now();
  for (let si = 0; si < STUDENTS.length; si++) {
    const s = STUDENTS[si];
    const pw = s.password ?? "student123";
    const studentData = {
      name: s.name, form: s.form,
      whatsapp: s.whatsapp ?? null,
      pdpaConsent: true, consentAt: new Date(),
    };
    const student = await prisma.student.upsert({
      where: { email: s.email }, update: studentData, create: { email: s.email, ...studentData },
    });
    await prisma.user.upsert({
      where: { email: s.email },
      update: { password: hashPassword(pw), role: "student", name: s.name, studentId: student.id },
      create: { email: s.email, name: s.name, role: "student", password: hashPassword(pw), studentId: student.id },
    });

    // Enrollments
    for (const subj of s.subjects) {
      const subjectId = subjectByName.get(subj);
      if (!subjectId) continue;
      await prisma.enrollment.upsert({
        where: { studentId_subjectId: { studentId: student.id, subjectId } },
        update: {}, create: { studentId: student.id, subjectId, status: "active" },
      });
    }

    // Payments (1–2 per student)
    await prisma.payment.create({ data: { studentId: student.id, ...PLANS[si % PLANS.length], paidAt: new Date(now - (si + 1) * 5 * 864e5) } });
    if (si % 2 === 0) {
      await prisma.payment.create({ data: { studentId: student.id, ...PLANS[(si + 2) % PLANS.length], paidAt: new Date(now - (si + 10) * 864e5) } });
    }

    // Attempts spread over the last ~3 weeks for trend analysis
    const pool = approvedQ.filter((q) => s.subjects.some((sub) => subjectByName.get(sub) === q.subjectId));
    const nAttempts = 5 + si * 2;
    for (let i = 0; i < nAttempts; i++) {
      const pick = pool[(i * 7 + si) % pool.length];
      if (!pick) continue;
      const q = await prisma.question.findUnique({ where: { id: pick.id } });
      if (!q) continue;
      // Vary performance: some students stronger than others.
      const base = 0.4 + (si % 4) * 0.12 + (Math.sin(i) + 1) * 0.12;
      const ratio = Math.max(0, Math.min(1, base));
      const score = Math.round(q.marks * ratio);
      await prisma.attempt.create({
        data: {
          studentId: student.id, questionId: q.id, answer: q.questionType === "mcq" ? (q.answer ?? "A") : "Jawapan contoh pelajar.",
          score, maxScore: q.marks, isCorrect: q.questionType === "mcq" ? score === q.marks : null,
          band: null, feedback: JSON.stringify({ summary: "Seeded attempt.", strengths: [], improvements: [], criteria: [] }),
          gradedByAi: false, timeSpentSec: 60 + i * 20, createdAt: new Date(now - (nAttempts - i) * 1.5 * 864e5),
        },
      });
    }

    await prisma.studySession.create({ data: { studentId: student.id, durationSec: 1200 + si * 600, questionsDone: nAttempts } });
  }

  const counts = {
    subjects: await prisma.subject.count(), topics: await prisma.topic.count(),
    questionsApproved: await prisma.question.count({ where: { status: "approved" } }),
    questionsPending: await prisma.question.count({ where: { status: "pending" } }),
    users: await prisma.user.count(), students: await prisma.student.count(),
    enrollments: await prisma.enrollment.count(), payments: await prisma.payment.count(),
    attempts: await prisma.attempt.count(),
  };
  console.log("Seed complete:", counts);
  console.log("Logins → admin@spm.my/Admin123@ · vikhash@student.spm.my/Vikhash123@");
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(async () => { await prisma.$disconnect(); });
