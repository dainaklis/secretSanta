# Secret Santa internetu (8 dalyviai)

Ši versija pritaikyta GitHub Pages + Supabase. Visi atidaro tą pačią nuorodą telefone arba kompiuteryje. Kiekvienas dalyvis pasirenka savo vardą, o serveris saugiai grąžina tik jo paties ištrauktą vardą.

## 1. Sukurk Supabase projektą

1. Eik į https://supabase.com/ ir prisijunk / susikurk paskyrą.
2. Sukurk naują projektą (New project). Užsirašyk duomenų bazės slaptažodį.
3. Atidaryk **SQL Editor** -> **New query**.
4. Atidaryk `supabase-setup.sql`, nukopijuok visą turinį į SQL Editor ir spausk **Run**.
5. Supabase projekto nustatymuose atidaryk **Authentication -> Sign In / Providers** ir įjunk **Anonymous Sign-Ins** (anoniminius prisijungimus).
6. Atidaryk **Project Settings -> API** (arba API Keys). Nukopijuok Project URL ir publishable key (senesnėje sąsajoje gali būti vadinamas `anon` / `public` key).

## 2. Įrašyk Supabase raktus į index.html

Atidaryk `index.html` ir surask:

```js
const SUPABASE_URL = "ĮRAŠYK_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "ĮRAŠYK_SUPABASE_PUBLISHABLE_KEY";
```

Pakeisk reikšmes savo Supabase Project URL ir publishable/anon public key. **Nenaudok `service_role` arba secret key** – jų negalima dėti į naršyklės kodą.

## 3. Įkelk į GitHub

1. GitHub susikurk naują repository, pvz. `secret-santa`.
2. Įkelk į repository `index.html`. `supabase-setup.sql` ir `README.md` gali laikyti tame pačiame repo.
3. Atidaryk repository **Settings -> Pages**.
4. Prie **Build and deployment** pasirink **Deploy from a branch**.
5. Branch pasirink `main`, aplanką `/ (root)`, spausk **Save**.
6. Palauk, kol GitHub Pages parodys svetainės adresą, pvz. `https://TAVO-VARDAS.github.io/secret-santa/`.
7. Atsiųsk tą pačią nuorodą visiems 8 dalyviams.

## 4. Kaip naudotis

1. Kiekvienas atsidaro bendrą GitHub Pages nuorodą.
2. Spaudžia „Pradėti žaidimą“.
3. Kiekvienas pasirenka savo vardą ir spaudžia „Patvirtinti savo vardą“.
4. Spaudžia „Traukti kortelę“.
5. Kortelė parodo tik jam skirtą vardą. Po 8 sekundžių ji užsidaro.
6. Jei tas pats žmogus tame pačiame naršyklės profilyje grįžta į puslapį, jis gali peržiūrėti savo tą patį rezultatą dar kartą.

## Privatumas ir svarbūs apribojimai

- GitHub puslapis saugo tik programos sąsają; bendri duomenys saugomi Supabase.
- Tiesioginė prieiga prie lentelių uždrausta. Kortelės vardas grąžinamas tik pagal anoniminio prisijungimo ID.
- Vardas pririšamas prie naršyklės anoniminės sesijos. Jei išvalomi naršyklės duomenys arba naudojamas kitas įrenginys / naršyklės profilis, dalyvis gali nebeatpažinti savo ankstesnės sesijos. Todėl kiekvienas turėtų naudoti tą patį įrenginį ir naršyklę iki žaidimo pabaigos.
- Vardų pasirinkimas nėra tikra asmens tapatybės patikra: nuorodą gavęs žmogus gali bandyti pasirinkti dar neužimtą vardą. Siųsk nuorodą tik 8 dalyviams.
- Nenaudok Supabase `service_role` / secret key viešame HTML faile.

## Naujas žaidimas

Šis projektas skirtas vienam traukimui. Naujam žaidimui reikės iš naujo paruošti Supabase duomenų bazę ir sugeneruoti naują paskirstymą. Nedaryk to, kol visi neperžiūrėjo savo kortelių.
