module KernelDesk.Notice exposing (attention, success)

import KernelDesk.Types exposing (Notice, NoticeKind(..))


success : String -> Notice
success message =
    { kind = Positive, message = message }


attention : String -> Notice
attention message =
    { kind = Attention, message = message }
