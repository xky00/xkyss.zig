const webui = @import("webui");

pub fn main() !void {
    var nwin = webui.newWindow();
    _ = nwin.show("<html><head><script src=\"webui.js\"></script></head> Hello World ! </html>");
    webui.wait();
}

/////////////////////////
// local site

// const std = @import("std");
// const webui = @import("webui");

// fn close(_: webui.Event) void {
//     std.debug.print("Exit.\n", .{});

//     webui.exit();
// }

// pub fn main() !void {
//     var mainW = webui.newWindow();

//     _ = mainW.setPort(8088);
//     _ = mainW.setRootFolder("qwik");

//     _ = mainW.bind("__close-btn", close);

//     if (!mainW.showBrowser("index.html", .ChromiumBased)) {
//         _ = mainW.show("index.html");
//     }

//     webui.wait();

//     webui.clean();
// }
