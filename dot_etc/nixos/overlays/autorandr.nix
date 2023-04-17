self: super:

{
  autorandr = assert (super.autorandr.version == "1.12.1"); super.unstable.autorandr;
}

