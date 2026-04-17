# Bruin AI Analyst Context

Folder ini dipakai untuk membangun `Bruin AI analyst` context dari tabel BigQuery proyek utama.

Tujuannya:

- mengimpor schema warehouse menjadi asset Bruin
- memberi context yang bisa dibaca AI assistant
- menyiapkan langkah `bruin ai enhance`
- membantu menjawab pertanyaan bisnis dengan `bruin query`

Schema yang diprioritaskan:

- `crude_oil_mart`
- `crude_oil_staging`

Perintah dasar:

```bash
export PATH=$HOME/.local/bin:$PATH
export BRUIN_HOME=/tmp/.bruin
set -a
source .env
set +a

bruin import database --connection gcp --schema crude_oil_mart ai-analyst
bruin import database --connection gcp --schema crude_oil_staging ai-analyst
```
