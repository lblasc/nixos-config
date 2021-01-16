{ lib
, vscode-utils
, terraform-ls
, jq
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "terraform";
    publisher = "HashiCorp";
    version = "2.2.3";
    sha256 = "0ypc6difv808d6k1ndjrxdxd75p71w9xwvcfj2ygpdxdlqshkhdk";
  };

  nativeBuildInputs = [ jq ];

  preInstall = ''
    jq '.contributes.configuration.properties."terraform.languageServer".default.pathToBinary = $s' \
      --arg s "${terraform-ls}/bin/terraform-ls" \
      package.json >package.json.new
    mv package.json.new package.json
  '';

  meta = with lib; {
    description = "Syntax highlighting and autocompletion for Terraform";
    homepage = "https://github.com/hashicorp/vscode-terraform.git";
    #license = with licenses; [ mpl ];
    maintainers = with maintainers; [ lblasc ];
    platforms = platforms.all;
  };
}
