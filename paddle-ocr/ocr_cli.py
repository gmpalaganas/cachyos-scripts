"""
ocr_cli.py

Run PaddleOCR on a single image and print the recognized text to stdout,
one line per detected text line. Exits 0 if text was found, 1 otherwise.

Usage: ocr_cli.py <image_path>
"""

import json
import sys
import tempfile
from pathlib import Path

from paddleocr import PaddleOCR


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: ocr_cli.py <image_path>", file=sys.stderr)
        return 2

    image_path = sys.argv[1]

    ocr = PaddleOCR(
        use_doc_orientation_classify=False,
        use_doc_unwarping=False,
        use_textline_orientation=False,
        engine="paddle",
    )

    result = ocr.predict(image_path)

    all_texts = []
    with tempfile.TemporaryDirectory() as tmp_dir:
        for res in result:
            res.print()
            res.save_to_json(tmp_dir)

        for json_file in Path(tmp_dir).glob("*.json"):
            with open(json_file, encoding="utf-8") as f:
                data = json.load(f)
            all_texts.extend(data.get("rec_texts", []))

    output_text = "\n".join(all_texts)

    if output_text.strip():
        print(output_text)
        return 0
    else:
        return 1


if __name__ == "__main__":
    sys.exit(main())
