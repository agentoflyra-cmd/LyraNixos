{
  let
    nixos = "age1v7rdcvzlxw4eeq7xz3vguka99w3uxk9c66gu745ulvwmpqwc5dgshxchq3";
  in
  {
    "github-token.age".publicKeys = [ nixos ];
  }
}
