@Builder
export function SimpleDialogBuilder(message: string, close: () => void) {
  SimpleDialog({
    content: message,
    close
  })
}

@CustomDialog
export struct SimpleDialog {
  @Prop @Require content: string = '';
  close: () => void = () => {
  }
  controller?: CustomDialogController;

  build() {
    Column() {
      Text(this.content)
        .fontSize(15)
        .height(70)
      Button('Close')
        .onClick(() => {
          if (this.controller !== undefined) {
            this.controller.close();
          }
          this.close();
        })
        .margin(20)
    }
  }
}