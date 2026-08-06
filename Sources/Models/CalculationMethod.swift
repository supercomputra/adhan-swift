//
//  CalculationMethod.swift
//  Adhan
//
//  Copyright © 2018 Batoul Apps. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/**
 Preset calculation parameters for different regions.
 
 *Descriptions of the different options*
 
 **muslimWorldLeague**
 
 Muslim World League. Standard Fajr time with an angle of 18°. Earlier Isha time with an angle of 17°.
 
 **egyptian**
 
 Egyptian General Authority of Survey. Early Fajr time using an angle 19.5° and a slightly earlier Isha time using an angle of 17.5°.
 
 **karachi**
 
 University of Islamic Sciences, Karachi. A generally applicable method that uses standard Fajr and Isha angles of 18°.
 
 **ummAlQura**
 
 Umm al-Qura University, Makkah. Uses a fixed interval of 90 minutes from maghrib to calculate Isha. And a slightly earlier Fajr time
 with an angle of 18.5°. Note: you should add a +30 minute custom adjustment for Isha during Ramadan.
 
 **dubai**
 
 Used in the UAE. Slightly earlier Fajr time and slightly later Isha time with angles of 18.2° for Fajr and Isha in addition to 3 minute
 offsets for sunrise, Dhuhr, Asr, and Maghrib.
 
 **moonsightingCommittee**
 
 Method developed by Khalid Shaukat, founder of Moonsighting Committee Worldwide. Uses standard 18° angles for Fajr and Isha in addition
 to seasonal adjustment values. This method automatically applies the 1/7 approximation rule for locations above 55° latitude.
 Recommended for North America and the UK.
 
 **northAmerica**

 Also known as the ISNA method. Can be used for North America, but the moonsightingCommittee method is preferable. Gives later Fajr times and early
 Isha times with angles of 15°. Matches the Fiqh Council of North America's current fixed-angle recommendation for the USA specifically
 (15°/15°, year-round); see `fiqhCouncilNorthAmericaCanada` for the Council's separate Canada recommendation (13°/13°).
 
 **kuwait**
 
 Standard Fajr time with an angle of 18°. Slightly earlier Isha time with an angle of 17.5°.
 
 **qatar**
 
 Same Isha interval as `ummAlQura` but with the standard Fajr time using an angle of 18°.
 
 **singapore**
 
 Used in Singapore, Malaysia, and Indonesia. Early Fajr time with an angle of 20° and standard Isha time with an angle of 18°.
 
 **malaysia**

 Jabatan Kemajuan Islam Malaysia (JAKIM). Early Fajr time with an angle of 20° and standard Isha
 time with an angle of 18°. Same angles as `singapore`; kept as a separate case for
 discoverability and to allow method-specific offsets to diverge in the future. Note: the state
 of Kelantan uses a 19° Fajr angle, which is not modeled separately.

 **indonesia**

 Kementerian Agama Republik Indonesia (Kemenag). This preset's figures are evidenced to different
 degrees; each claim below is labeled with what actually supports it, so "we modeled X" and "we
 could not confirm X" aren't blurred together.

 Method, per the actual official manual — Kementerian Agama RI, Buku Saku Hisab Rukyat (Direktorat
 Pembinaan Syariah dan Hisab Rukyat, Direktorat Urusan Agama Islam dan Pembinaan Syariah, Direktorat
 Jenderal Bimbingan Masyarakat Islam, Kementerian Agama RI, 2013), pp. 82–91, read directly from a
 copy hosted on Kemenag's own digital library (simbi.kemenag.go.id/eliterasi) — is not simply fixed
 angles per prayer. It is relative to one shared elevation-corrected horizon reference:
 - h₀(terbit/terbenam) = -(refraksi + semidiameter + kerendahan ufuk) = -(0°34′ + 0°16′ + ku), with
   ku = 0°1.76″·√(elevation in meters). This is what this preset's `maghribAngle: 1` approximates:
   at sea level it is exactly -50′ = -0.833° (this library's ordinary geometric-sunset default); the
   book's own worked example, for Jakarta at an assumed 200 m elevation, computes it as -1°04′44″.
 - h₀(Isya) = -17° + h₀(terbit/terbenam) — not a bare -18°.
 - h₀(Subuh) = -19° + h₀(terbit/terbenam) — not a bare -20°.
 - h(Asr) via cot(h) = tan(zm) + 1, zm = |δ - φ| — the standard Shafi shadow-length formula.
 - Dhuhr at meridian transit — the standard definition, no angle involved.
 - Ihtiyat, per the book's own words (p. 83): round any number of seconds up to the next whole
   minute for every prayer except Terbit (where seconds are simply discarded), then add 2 minutes to
   Subuh/Zuhur/Asar/Maghrib/Isya and subtract 2 minutes from Terbit and Imsak. The book's full worked
   example (Jakarta, 17 August 2013) demonstrates this for Dhuhur explicitly: raw 11:56:50 → seconds
   rounded up → 11:57 → +2 min ihtiyat → 11:59 WIB.

 This library has no elevation parameter, so the sea-level-adjacent `maghribAngle: 1` below is used
 as a fixed stand-in for the elevation-corrected value rather than computing it per location. This
 library's Fajr/Isha angles (20°/18°) are also a simplification of the book's elevation-relative
 formula, not a literal transcription of it — at sea level the book's formula works out to roughly
 -19.83°/-17.83°, about 0.17° off from this preset's 20°/18° — but see CONFIRMED below for why the
 simplification is still empirically justified.

 A second, independent source — Unggul Suryo Ardi, "Problematika Awal Waktu Shubuh antara Fiqih dan
 Astronomi," AL-AFAQ: Jurnal Ilmu Falak dan Astronomi (Fakultas Syariah, Universitas Islam Negeri
 Mataram), Vol. 2 No. 2, Desember 2020, P-ISSN 2685-0176 / E-ISSN 2722-0176, pp. 87–98 — states
 directly (p. 93) that -20° for Subuh "digunakan saat ini oleh KEMENAG Indonesia" (currently used by
 Kemenag Indonesia), corroborating that the -20° simplification above is genuinely current practice
 and not just this preset's own rounding. A third, non-official source,
 https://aliboron.wordpress.com/2013/05/12/hisab-waktu-waktu-shalat/ (Akhmad Syaikhu, S.Ag., S.S.,
 M.S.I., M.H.I., an Indonesian academic who has served as public-relations sub-division head —
 Kasubbag Humas — for IAIN Antasari, now UIN Antasari Banjarmasin, but still a personal/study blog
 post, not a Kemenag publication) restates the same -20°/-18°/-1° simplification in more accessible
 form, cited here alongside the official book above as a second, independent statement of the same
 figures.

 Since the official book is from 2013, its angle criteria were checked for staleness: as recently as
 2 December 2025, Kemenag officials Arsad Hidayat (Direktur Urusan Agama Islam dan Bina Syariah) and
 Ismail Fahmi (Kasubdit Hisab Rukyat dan Syariah) publicly reaffirmed -20° for Subuh, specifically in
 response to Muhammadiyah's competing -18° proposal (reported by detik.com and cahaya.kompas.com,
 both dated 2 December 2025) — so the angle criteria are current, not a stale 2013 figure.

 CONFIRMED, by the official book, corroborating sources, and primary-source data together:
 - Fajr angle 20°, Isha angle 18° — a documented simplification of the book's elevation-relative
   formula (see Method above), independently corroborated as current Kemenag practice by the AL-AFAQ
   article, and empirically producing ~0 min residual offset against real Kemenag output (below) —
   close enough that the ~0.17° simplification gap is absorbed by this library's ceiling rounding.
 - Maghrib angle 1° below the horizon (`maghribAngle: 1`), not this library's usual geometric sunset
   (~0.833° below the horizon) — matches the book's own worked example (-1°04′44″ at 200 m
   elevation). Two candidate models were compared against the primary-source data (below): a flat
   +3 min minute-level adjustment on top of plain geometric sunset, fit empirically from Jakarta data
   alone, matches only 81/123 sampled dates exactly; `maghribAngle: 1` plus the book's documented
   +2 min ihtiyat (not a fitted value) matches 118/123 dates exactly, so this preset uses the latter.
 - Asr's shadow-length formula matches the official book directly: this library's existing
   Shafi-shadow calculation already implements cot(h) = tan(zm) + 1.
 - Fajr, Asr, Maghrib, and Isha ihtiyat of +2 min each — matches the book's explicit rule, and (below)
   matches primary-source data at all three test cities.

 CONFIRMED, by primary-source data alone (no independent formula source gives this exact minute
 value):
 - Terbit (sunrise) adjustment of -4 min (`sunrise: -4`). This library has neither an elevation
   parameter nor a per-method sunrise angle override, so the book's elevation-relative h₀ formula
   (see Method above) cannot be computed directly for Terbit the way it can for Maghrib; -4 min is a
   flat empirical fit against primary-source data instead. The fit is the same shape as Dzuhur/Ashar/
   Maghrib above: one dominant value with occasional ±1 min jitter, not scattered noise — at all
   three test cities, the raw offset (Kemenag's Terbit minus this library's unadjusted sunrise) was
   -4 min roughly two-thirds of the time and -3 min the rest (Jakarta 81/123 vs 42/123, Sabang 19/31
   vs 12/31, Merauke 38/62 vs 24/62), never any other value. Applying -4 min brings the residual to
   0 or +1 min at every one of the 216 sampled dates across all three cities.

 CONTRADICTED by the official book, followed anyway because it matches what Kemenag's live system
 actually outputs today:
 - Dhuhr ihtiyat of +3 min. The book's own worked example computes Dhuhr with the same +2 min rule
   as every other prayer (11:56:50 → 11:57 → 11:59 WIB) — not +3. But the primary-source comparison
   below, run against bimasislam.kemenag.go.id's live output (not the 2013 book), consistently and
   repeatably shows +3, not +2, at all three test cities. Since this preset's purpose is to match
   what Kemenag's system actually publishes today, the live data is followed over the 13-years-older
   book; whether that reflects a deliberate policy change since 2013 or something else was not
   determined, and is worth revisiting if a newer official document surfaces.

 Confirmed by comparing this library's computed output against Kemenag's own primary-source data
 (the JSON returned by `POST https://bimasislam.kemenag.go.id/ajax/getShalatbln`) at three
 locations spanning both of Indonesia's time zones and its full longitude range: DKI Jakarta /
 Kota Jakarta (-6.1751, 106.8272, WIB, 123 dates across January 2025, July 2024, March 2022, and
 November 2026), Aceh / Kota Sabang (5.8933, 95.3214, WIB, 31 dates in August 2026), and Papua /
 Kabupaten Merauke (-8.4667, 140.4000, WIT, 62 dates across January 2024 and August 2026). With the
 angle and ihtiyat adjustments above, residual offsets (Kemenag minus this library's computation)
 were ~0 min at all three locations for every adjusted prayer, within ±1 min rounding-boundary
 jitter (e.g. Jakarta Dzuhur 122/123 exact, Ashar 117/123 exact, Maghrib 118/123 exact, Terbit
 exact-or-+1 at all 123 dates; Merauke and Sabang matched at least as tightly).

 SUMMARY — how each parameter below was actually decided:
 - `fajrAngle: 20`, `ishaAngle: 18` — official book's formula, simplified to fixed angles;
   corroborated by an independent academic source; ~0 min residual against primary-source data.
 - `maghribAngle: 1` — official book's formula and worked example directly; ~0 min residual.
 - Asr shadow formula — the standard shadow-length formula, matching the official book directly.
 - Dhuhr at meridian transit — the standard definition, matching the official book directly.
 - `methodAdjustments`: `fajr: 2`, `asr: 2`, `maghrib: 2`, `isha: 2` — official book's explicit
   ihtiyat rule; confirmed against primary-source data.
 - `methodAdjustments.dhuhr: 3` — primary-source data only; contradicts the official book's own
   worked example (which computes +2, like every other prayer). Data wins because this preset's
   goal is to match what Kemenag's live system outputs today, not the 2013 text.
 - `methodAdjustments.sunrise: -4` — primary-source data only, since no per-method sunrise angle
   exists in this library to compute the book's formula directly for Terbit.

 **tehran**
 
 Institute of Geophysics, University of Tehran. Early Isha time with an angle of 14°. Slightly later Fajr time with an angle of 17.7°.
 Calculates Maghrib based on the sun reaching an angle of 4.5° below the horizon.
 
 **turkey**

 An approximation of the Diyanet method used in Turkey. This approximation is less accurate outside the region of Turkey.

 **uoifFrance**

 Union des Organisations Islamiques de France (now "Musulmans de France"). Uses a fixed angle of 12° for both Fajr and Isha,
 corresponding to nautical twilight. The most widely followed method among mosques in Paris and Île-de-France.

 **fiqhCouncilNorthAmericaCanada**

 Fiqh Council of North America's Canada-specific recommendation. Uses a fixed angle of 13° for both Fajr and Isha, applied
 throughout the year. Distinct from the Council's USA recommendation of 15°/15° (see `northAmerica`).

 **other**
 
 Defaults to angles of 0°, should generally be used for making a custom method and setting your own values.
 
 */
public enum CalculationMethod: String, Codable, CaseIterable {
    
    // Muslim World League
    case muslimWorldLeague
    
    // Egyptian General Authority of Survey
    case egyptian
    
    // University of Islamic Sciences, Karachi
    case karachi
    
    // Umm al-Qura University, Makkah
    case ummAlQura
    
    // UAE
    case dubai
    
    // Moonsighting Committee
    case moonsightingCommittee
    
    // ISNA
    case northAmerica
    
    // Kuwait
    case kuwait
    
    // Qatar
    case qatar
    
    // Singapore
    case singapore
    
    // Jabatan Kemajuan Islam Malaysia (JAKIM)
    case malaysia

    // Kementerian Agama Republik Indonesia (Kemenag)
    case indonesia

    // Institute of Geophysics, University of Tehran
    case tehran
    
    // Dianet
    case turkey

    // Union des Organisations Islamiques de France (Musulmans de France)
    case uoifFrance

    // Fiqh Council of North America, Canada-specific recommendation
    case fiqhCouncilNorthAmericaCanada

    // Other
    case other
    
    public var params: CalculationParameters {
        switch(self) {
        case .muslimWorldLeague:
            var params = CalculationParameters(fajrAngle: 18, ishaAngle: 17, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 1)
            return params
        case .egyptian:
            var params = CalculationParameters(fajrAngle: 19.5, ishaAngle: 17.5, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 1)
            return params
        case .karachi:
            var params = CalculationParameters(fajrAngle: 18, ishaAngle: 18, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 1)
            return params
        case .ummAlQura:
            return CalculationParameters(fajrAngle: 18.5, ishaInterval: 90, method: self)
        case .dubai:
            var params = CalculationParameters(fajrAngle: 18.2, ishaAngle: 18.2, method: self)
            params.methodAdjustments = PrayerAdjustments(sunrise: -3, dhuhr: 3, asr: 3, maghrib: 3)
            return params
        case .moonsightingCommittee:
            var params = CalculationParameters(fajrAngle: 18, ishaAngle: 18, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 5, maghrib: 3)
            return params
        case .northAmerica:
            var params = CalculationParameters(fajrAngle: 15, ishaAngle: 15, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 1)
            return params
        case .kuwait:
            return CalculationParameters(fajrAngle: 18, ishaAngle: 17.5, method: self)
        case .qatar:
            return CalculationParameters(fajrAngle: 18, ishaInterval: 90, method: self)
        case .singapore:
            var params = CalculationParameters(fajrAngle: 20, ishaAngle: 18, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 1)
            params.rounding = .up
            return params
        case .malaysia:
            var params = CalculationParameters(fajrAngle: 20, ishaAngle: 18, method: self)
            params.methodAdjustments = PrayerAdjustments(dhuhr: 1)
            params.rounding = .up
            return params
        case .indonesia:
            var params = CalculationParameters(fajrAngle: 20, maghribAngle: 1, ishaAngle: 18, method: self)
            params.methodAdjustments = PrayerAdjustments(fajr: 2, sunrise: -4, dhuhr: 3, asr: 2, maghrib: 2, isha: 2)
            params.rounding = .up
            return params
        case .tehran:
            return CalculationParameters(fajrAngle: 17.7, maghribAngle: 4.5, ishaAngle: 14, method: self)
        case .turkey:
            var params = CalculationParameters(fajrAngle: 18, ishaAngle: 17, method: self)
            params.methodAdjustments = PrayerAdjustments(fajr: 0, sunrise: -7, dhuhr: 5, asr: 4, maghrib: 7, isha: 0)
            return params
        case .uoifFrance:
            return CalculationParameters(fajrAngle: 12, ishaAngle: 12, method: self)
        case .fiqhCouncilNorthAmericaCanada:
            return CalculationParameters(fajrAngle: 13, ishaAngle: 13, method: self)
        case .other:
            return CalculationParameters(fajrAngle: 0, ishaAngle: 0, method: self)
        }
    }

    /**
     Returns the `CalculationMethod`(s) recommended for a given country, based on the method(s) used
     or endorsed by that country's official Islamic/religious affairs authority. The first element is
     the most-recommended method; when a country has more than one method in significant use, subsequent
     elements are ordered by how widely followed they are. Falls back to `[.muslimWorldLeague]`, the most
     widely adopted international default, for countries without a distinct official method or that are
     not recognized.

     - Parameter countryCode: An ISO 3166-1 alpha-2 country code (e.g. "ID", "US", "SA"). Matching is
     case-insensitive.
     */
    public static func recommended(for countryCode: String) -> [CalculationMethod] {
        switch countryCode.uppercased() {
        case "ID":
            // Indonesia — Kementerian Agama (Kemenag) sets Fajr at 20°/Isha at 18°, matching `.indonesia`.
            // Source: "Kriteria Waktu Subuh -20 Derajat Benar Secara Fikih dan Sains", Kemenag (kemenag.go.id).
            return [.indonesia]
        case "MY":
            // Malaysia — JAKIM (Jabatan Kemajuan Islam Malaysia) sets Fajr at 20°/Isha at 18°, matching `.malaysia`.
            // Source: "e-Solat Waktu Solat" methodology documentation, JAKIM (https://www.e-solat.gov.my/).
            return [.malaysia]
        case "SG":
            // Singapore — MUIS (Majlis Ugama Islam Singapura) sets Fajr at 20°/Isha at 18°, matching `.singapore`.
            // Source: "Prayer Times" official timetable methodology, MUIS (https://www.muis.gov.sg/).
            return [.singapore]
        case "US":
            // United States — Fiqh Council of North America's current fixed-angle recommendation is
            // 15°/15° (`.northAmerica`); Moonsighting Committee Worldwide's seasonal method (18° baseline)
            // is also widely followed.
            // Sources: "How should the times of Fajr and Isha be calculated?", Fiqh Council of North
            // America (fiqhcouncil.org/the-suggested-calculation-method-for-fajr-and-isha/);
            // "How We Calculate Muslim Prayer Times", Moonsighting.com (moonsighting.com/how-we.html).
            return [.northAmerica, .moonsightingCommittee]
        case "CA":
            // Canada — Fiqh Council of North America recommends 13°/13° specifically for Canada
            // (`.fiqhCouncilNorthAmericaCanada`), distinct from its 15°/15° USA recommendation;
            // Moonsighting Committee Worldwide's seasonal method is also widely followed.
            // Sources: "How should the times of Fajr and Isha be calculated?", Fiqh Council of North
            // America (fiqhcouncil.org/the-suggested-calculation-method-for-fajr-and-isha/);
            // "How We Calculate Muslim Prayer Times", Moonsighting.com (moonsighting.com/how-we.html).
            return [.fiqhCouncilNorthAmericaCanada, .moonsightingCommittee]
        case "GB":
            // United Kingdom — Moonsighting Committee Worldwide's seasonal/latitude-based method
            // (18° baseline) is the most widely followed among UK mosques; Muslim World League
            // (18°/17°) is also commonly used.
            // Source: "How We Calculate Muslim Prayer Times", Moonsighting.com (moonsighting.com/how-we.html).
            return [.moonsightingCommittee, .muslimWorldLeague]
        case "FR":
            // France — UOIF ("Musulmans de France") uses a fixed 12°/12° angle (nautical twilight),
            // described as the most widely followed convention among Paris/Île-de-France mosques;
            // Muslim World League (18°/17°) is also in use.
            // Source: "Méthodologie de Calcul des Horaires de Prière à Paris",
            // horairepriereparis.com/methodologie-calcul-horaires-priere-paris/.
            return [.uoifFrance, .muslimWorldLeague]
        case "SA":
            // Saudi Arabia — Umm al-Qura University, Makkah, the country's official method
            // (18.5° Fajr, 90 minute fixed Isha interval).
            return [.ummAlQura]
        case "AE":
            // UAE — `.dubai` is this library's long-standing preset for the UAE (18.2° Fajr/Isha with
            // sunrise/Dhuhr/Asr/Maghrib offsets), and AWQAF (General Authority of Islamic Affairs,
            // Endowments & Zakat) is the real governing body for the region, but a primary AWQAF
            // document stating 18.2° specifically could not be located. Independent secondary sources
            // instead describe AWQAF's official "Gulf method" as 19.5° Fajr with a fixed 90 minute
            // Isha interval, which does not exactly match any existing preset in this enum (closest is
            // `.ummAlQura` at 18.5°+90min). Kept as `.dubai` pending a citable primary source; flagged
            // as unconfirmed rather than authority-verified.
            //
            // REVISIT: considered adding a distinct `.gulfRegion` preset (19.5° Fajr, 90 min Isha) to
            // model this "Gulf method" — it's a named, distinct method in third-party APIs (e.g. Aladhan
            // API method ID 8, "Gulf Region"), attributed by multiple secondary sources to UAE Awqaf
            // and/or IACAD (Islamic Affairs and Charitable Activities Department, Dubai's own
            // emirate-level authority, distinct from the federal AWQAF). However, no primary document
            // from either awqaf.gov.ae or iacad.gov.ae could be located or fetched (cert error on
            // awqaf.gov.ae) stating this angle directly — every source found is aggregator-to-aggregator
            // citation with no traceable original. This is the same evidentiary tier as the existing
            // `.dubai` case, not an improvement, so no new preset was added. Revisit if a primary
            // AWQAF/IACAD document surfaces.
            return [.dubai]
        case "QA":
            // Qatar — Ministry of Awqaf and Islamic Affairs uses a fixed 90 minute Isha interval with
            // an 18° Fajr angle (`.qatar`); Umm al-Qura (18.5° Fajr, same 90 minute Isha interval) is
            // also cited as closely aligned and in use.
            return [.qatar, .ummAlQura]
        case "BH", "OM":
            // Bahrain, Oman — Umm al-Qura method (18.5° Fajr, fixed 90 minute Isha interval).
            // Bahrain source: "Umm Al-Qura Calculation Method", bahrainprayerstime.com
            // (bahrainprayerstime.com/blog/umm-al-qura-calculation-method/).
            // Oman source: "Oman Calendar" app, Ministry of Endowments and Religious Affairs (Oman).
            return [.ummAlQura]
        case "KW":
            // Kuwait — 18° Fajr / 17.5° Isha, widely documented as the Kuwaiti official standard,
            // matching `.kuwait` exactly.
            return [.kuwait]
        case "EG", "LY", "SD":
            // Egypt, Libya, Sudan — Egyptian General Authority of Survey (19.5° Fajr / 17.5° Isha),
            // matching `.egyptian` exactly. Libya and Sudan have no distinct national standard of
            // their own documented; the Egyptian method is consistently reported as the one in
            // common use across both countries.
            return [.egyptian]
        case "MR":
            // Mauritania — no strongly-documented official national standard found; Umm al-Qura is
            // reported (with low confidence) as the method used for daily timings.
            return [.ummAlQura]
        case "PK", "IN", "BD", "AF":
            // Pakistan, India, Bangladesh, Afghanistan — University of Islamic Sciences, Karachi (18°/18°)
            // is documented as the common method across this region.
            return [.karachi]
        case "IR":
            // Iran — Institute of Geophysics, University of Tehran (17.7° Fajr / 14° Isha), matching `.tehran`.
            return [.tehran]
        case "TR":
            // Türkiye — Diyanet İşleri Başkanlığı, approximated by `.turkey`.
            return [.turkey]
        case "TN":
            // Tunisia — commonly attributed to the Ministry of Religious Affairs at Fajr/Isha both 18°,
            // matching `.karachi` (18°/18°), but no primary ministry document stating the angle was
            // found; treat as an unconfirmed regional convention rather than an authority-verified figure.
            return [.karachi]
        case "DZ":
            // Algeria — Ministry of Religious Affairs, Fajr 18°/Isha 17°, matching `.muslimWorldLeague` exactly.
            return [.muslimWorldLeague]
        case "MA":
            // Morocco — reported 19° angle; no exact preset exists, `.muslimWorldLeague` (18°/17°) is
            // the closest available approximation.
            return [.muslimWorldLeague]
        case "JO":
            // Jordan — Ministry of Awqaf, Islamic Affairs and Holy Places sets Fajr/Isha both at 18°
            // (plus an unmodeled +5 minute Maghrib offset), matching `.karachi` (18°/18°) most closely.
            // Source: api.aladhan.com method registry, id 23 "Ministry of Awqaf, Islamic Affairs and
            // Holy Places, Jordan" (api.aladhan.com/v1/methods).
            return [.karachi]
        case "SY", "LB", "PS":
            // Syria, Lebanon, Palestine — no distinct official calculation method is registered for
            // any of these three by name. aladhan.com, one of the most widely integrated prayer-time
            // APIs, has no dedicated method entry for Syria, Lebanon, or Palestine; querying its
            // location-based auto-detection for Damascus, Beirut, Ramallah, Jerusalem, and Gaza all
            // resolve to the same nearest registered authority — method id 23, Jordan's Ministry of
            // Awqaf, Islamic Affairs and Holy Places (Fajr/Isha both 18°) — making it the de facto
            // regional Levant reference. This matches `.karachi` (18°/18°) most closely.
            // Source: api.aladhan.com/v1/methods and api.aladhan.com/v1/timingsByCity (auto-detected
            // `data.meta.method`) for Damascus/SY, Beirut/LB, and Ramallah, Jerusalem, Gaza/PS,
            // queried 2026-08-06.
            return [.karachi]
        case "NG":
            // Nigeria — Karachi (18°/18°) is reported by aggregator-level sources as the most widely
            // followed method, but no official Nigerian religious authority (e.g. NASFAT, the Sultanate
            // Council) document confirming this was found; treat as unconfirmed.
            return [.karachi]
        case "GH":
            // Ghana — evidence is weak and conflicting: aggregator-level sources more often describe
            // Ghanaian mosques as following Muslim World League (18°/17°) than Karachi, with no
            // authoritative Ghanaian source found for either. Using `.muslimWorldLeague` as the better-
            // supported of the two; treat as unconfirmed.
            return [.muslimWorldLeague]
        case "PH":
            // Philippines — Karachi (18°/18°) is reported by aggregator-level sources as commonly used,
            // but the National Commission on Muslim Filipinos (NCMF) publishes Ramadan/fasting schedules
            // without a located statement tying them to this specific angle; treat as unconfirmed.
            return [.karachi]
        case "ZA":
            // South Africa — Karachi (18°/18°) is reported by aggregator-level sources as widely
            // followed, but no Muslim Judicial Council (MJC) document confirming this was found, and
            // some sources instead describe Muslim World League in use (e.g. Johannesburg); treat as
            // unconfirmed.
            return [.karachi]
        case "SN":
            // Senegal — Muslim World League (18°/17°) reported as the method in use.
            return [.muslimWorldLeague]
        case "NL":
            // Netherlands — VIN (Vereniging Imams Nederland) 2023/2024 agreement sets Fajr at 18°/Isha
            // at 17°, matching `.muslimWorldLeague` exactly.
            // Source: "Verklaring over Gebedstijden in Nederland voor het Jaar 2024", VIN
            // (moskeewijzer.nl/wp-content/uploads/2023/12/verklaring-vin-gebedstijden-2024-nl.pdf).
            return [.muslimWorldLeague]
        default:
            return [.muslimWorldLeague]
        }
    }
}
