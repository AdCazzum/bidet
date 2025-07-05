import binascii
import blake3

def generate_blake3_hash_decimal(bracelet_pk_decimal):
    if not (isinstance(bracelet_pk_decimal, list) and len(bracelet_pk_decimal) == 32):
        raise ValueError("Input 'bracelet_pk_decimal' deve essere una lista di 32 elementi.")

    try:
        byte_data = bytes(bracelet_pk_decimal)
    except ValueError as e:
        raise ValueError(f"Ogni elemento in 'bracelet_pk_decimal' deve essere un intero tra 0 e 255: {e}")

    hasher = blake3.blake3()
    hasher.update(byte_data)
    hash_bytes = hasher.digest() 
    bracelet_hash_decimal = list(hash_bytes)

    return bracelet_hash_decimal

if __name__ == "__main__":
    bracelet_pk_input = [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
        16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
    ]

    print(bracelet_pk_input)

    bracelet_hash_output = generate_blake3_hash_decimal(bracelet_pk_input)

    print(bracelet_hash_output)

    print("".join(map(lambda x: f"{x:02x}", bracelet_hash_output)))
