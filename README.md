# Avisynth-shenanigans
just updated (or possibly rewriten) scripts

### Ediaa
* Added 16 bit support
* (shameless copy of line0's Hiaa internal masking)

#####To-Do
use nnedi3_rpow2 instead of nnedi3+fturn

### DfttestMc
Added: 
* Recalculate
* (proper) 16 bit input handling
* dither_luma_rebuild
* some masking to prevent 16 bit data loss from 8 bit Mdegrain and Mcompensate

Limitations: Mdegrain and Mcompensate both only accept 8 bit input (and compensate even only 8 bit output) so keep in mind that running this script will result in minor 16 bit data loss.
So only call this filter early on in your 16 bit chain or run f3kdb afterwards.

#####To-Do
Possibly write some of the masking and frame duplicating more efficiently


Feel free to report issues