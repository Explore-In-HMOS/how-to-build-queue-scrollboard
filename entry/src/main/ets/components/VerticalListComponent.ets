import { QueueService } from '../service/QueueService';

@Component
export struct VerticalListComponent {
  @ObjectLink queue: QueueService;

  aboutToAppear(): void {
    this.queue.startInterval();
  }

  aboutToDisappear(): void {
    this.queue.destroy();
  }

  @Builder
  itemEnd() {
    Row() {
      Button('Delete')
        .margin('4vp')
    }
    .padding($r('sys.float.padding_level2'))
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  itemBuilder(item: string) {
    Row() {
      if (this.queue.isQueueCurrentItem(item)) {
        LoadingProgress()
          .color(Color.White)
          .width(40)
          .height(40)
      }
      Column() {
        Text(item)
          .fontSize(20)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
        Text(this.queue.getSubtitleText(item))
          .fontSize(8)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(50)
    .backgroundColor(this.queue.getBgColor(item))
    .borderRadius(40)
    .padding(2)
    .margin({ left: 5, right: 5 })
  }

  build() {
    Column() {
      Text(this.queue.currentQueue)
        .fontColor(Color.White)
        .fontSize(25)
        .align(Alignment.Center)
        .margin({ top: 10, bottom: 10 })
      List({ space: 5, initialIndex: 0, scroller: this.queue.listScroller }) {
        LazyForEach(this.queue.datasource, (item: string, index: number) => {
          ListItem() {
            this.itemBuilder(item);
          }
          .onAppear(() => {
            this.queue.onAppear(index);
          })
          .swipeAction({
            end: {
              builder: () => {
                this.itemEnd();
              },
              onAction: () => {
                this.getUIContext()?.animateTo({ duration: 1000 }, () => {
                  const index = this.queue.datasource.getAllData().indexOf(item);
                  this.queue.datasource.delete(index);
                  try {
                    this.queue.listScroller.closeAllSwipeActions()
                  } catch (error) {
                    console.error(`${error.code}: ${error.message}`);
                  }
                });
              }
            }
          })
          .onSelect((_) => {
            this.queue.showMessage(item);
          })
        }, (item: string) => item)
      }
      .width('100%')
      .height('100%')
      .cachedCount(5)
      .alignListItem(ListItemAlign.Center)
      .enableScrollInteraction(true)
      .onReachEnd(() => {
        this.queue.showMessage('Queue is finished.');
        this.queue.destroy();
      })
      .onScrollIndex((start: number, end: number) => {
        this.queue.visibleAreaChanged(start, end);
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}