import { QueueService } from '../service/QueueService';

@Component
export struct HorizontalInfiniteComponent {
  @ObjectLink queue: QueueService;

  aboutToAppear(): void {
    this.queue.startHorizontalInterval();
  }

  aboutToDisappear(): void {
    this.queue.destroy();
  }

  @Builder
  itemBuilder(item: string) {
    Text(item)
      .fontSize(25)
      .fontColor(Color.White)
      .backgroundColor('#1A1A1A')
      .borderRadius(15)
      .padding(5)
      .margin({
        left: 5,
        right: 5
      })
  }

  build() {
    Column() {
      List({ scroller: this.queue.scroller }) {
        LazyForEach(this.queue.datasource, (item: string) => {
          ListItem() {
            this.itemBuilder(item);
          }
        }, (item: string) => item)
      }
      .cachedCount(5)
      .onReachEnd(() => {
        this.queue.showMessage('Queue is finished.');
        this.queue.destroy();
      })
      .listDirection(Axis.Horizontal)
      .height(100)
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .onScrollIndex((start: number, end: number) => {
        this.queue.visibleAreaChanged(start, end);
      })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}