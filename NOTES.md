# Random Notes

## TODO

- [X] Reader software.
- [X] Analysis tool of bin files.
- [ ] Translation tool — from Arduino dump to bin.
- [ ] Writer software.

## Writing

Notes on writing and operation order:

- Probably no need to (re-)write the UID? If that's even possible?
    - TODO: Do different instances of the same Amiibo have different UIDs? I would assume yes.
- Write content.
- Update CC.
- Write static lock data.
- Write dynamic lock data.

## Capability Container

The Capability Container (CC), stored on page 0x03 is much different between a stock NTAG215 chip and an Amiibo. This normally holds some model-number type information so that the reader knows what device it's reading and how many pages to expect. The four bytes in this page normally look like the following for NTAG215:

```
0xE1 0x10 0x3E 0x00
```

The value in byte 2 (`0x3E`) specifically indicates how much memory is available in the tag.

The interesting thing about this page is that you can only _*set*_ bits, you cannot clear them. It's like the opposite of NAND Flash, where bytes start out as 0xFF and you can only clear bits. In the NTAG, any byte you write into a position in the page is ORed with the existing content. This means we can only add bits to the above bytes. The Amiibo CC content looks like this:

```
0xF1 0x10 0xFF 0xEE
```

## Locked Payload?

We know that page 22 and 23 (0x16 and 0x17) are an Amiibo identifier. What is the rest? Textual information? Bitmap? Stats? Why is there so much extra data?

## User Payload?

What content and format is stored in the read/write section of the payload? The owner (in what form — user ID, username, Mii?) and some limited save game data?
