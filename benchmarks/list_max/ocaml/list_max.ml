exception Empty_list

(* want to set higher, stack overflow is annoying *)
let bound = 2000000

let rec max_h x l =
  match l with
  | [] -> x
  | a :: b -> if a > x then max_h a b else max_h x b

let list_max l =
  match l with
  | [] -> raise Empty_list
  | a :: b -> max_h a b

let rec myrange_h k x =
  if k = 0 then 0 :: x else myrange_h (k-1) (k :: x)

let mrange_t k = myrange_h (k-1) []

let rec myrange x k =
  if x = 0 then [] else
    k :: myrange (x-1) (k+1)

let mrange k = myrange k 0

let _ = print_int (list_max (mrange bound))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 1)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 2)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 3)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 4)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 5)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 6)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 7)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 8)))
let _ = print_string "\n"
let _ = print_int (list_max (mrange (bound - 9)))
let _ = print_string "\n"
    

  
