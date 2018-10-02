using System;
using System.Runtime.InteropServices;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

namespace Godot
{
    [StructLayout(LayoutKind.Sequential)]
    public struct Rect2 : IEquatable<Rect2>
    {
        private Vector2 position;
        private Vector2 size;

        public Vector2 Position
        {
            get { return position; }
            set { position = value; }
        }

        public Vector2 Size
        {
            get { return size; }
            set { size = value; }
        }

        public Vector2 End
        {
            get { return position + size; }
        }

        public real_t Area
        {
            get { return GetArea(); }
        }

        public Rect2 Clip(Rect2 b)
        {
            var newRect = b;

            if (!Intersects(newRect))
                return new Rect2();

            newRect.position.x = Mathf.Max(b.position.x, position.x);
            newRect.position.y = Mathf.Max(b.position.y, position.y);

            Vector2 bEnd = b.position + b.size;
            Vector2 end = position + size;

            newRect.size.x = Mathf.Min(bEnd.x, end.x) - newRect.position.x;
            newRect.size.y = Mathf.Min(bEnd.y, end.y) - newRect.position.y;

            return newRect;
        }

        public bool Encloses(Rect2 b)
        {
            return b.position.x >= position.x && b.position.y >= position.y &&
               b.position.x + b.size.x < position.x + size.x &&
               b.position.y + b.size.y < position.y + size.y;
        }

        public Rect2 Expand(Vector2 to)
        {
            var expanded = this;

            Vector2 begin = expanded.position;
            Vector2 end = expanded.position + expanded.size;

            if (to.x < begin.x)
                begin.x = to.x;
            if (to.y < begin.y)
                begin.y = to.y;

            if (to.x > end.x)
                end.x = to.x;
            if (to.y > end.y)
                end.y = to.y;

            expanded.position = begin;
            expanded.size = end - begin;

            return expanded;
        }

        public real_t GetArea()
        {
            return size.x * size.y;
        }

        public Rect2 Grow(real_t by)
        {
            var g = this;

            g.position.x -= by;
            g.position.y -= by;
            g.size.x += by * 2;
            g.size.y += by * 2;

            return g;
        }

        public Rect2 GrowIndividual(real_t left, real_t top, real_t right, real_t bottom)
        {
            var g = this;

            g.position.x -= left;
            g.position.y -= top;
            g.size.x += left + right;
            g.size.y += top + bottom;

            return g;
        }

        public Rect2 GrowMargin(Margin margin, real_t by)
        {
            var g = this;

            g.GrowIndividual(Margin.Left == margin ? by : 0,
                    Margin.Top == margin ? by : 0,
                    Margin.Right == margin ? by : 0,
                    Margin.Bottom == margin ? by : 0);

            return g;
        }

        public bool HasNoArea()
        {
            return size.x <= 0 || size.y <= 0;
        }

        public bool HasPoint(Vector2 point)
        {
            if (point.x < position.x)
                return false;
            if (point.y < position.y)
                return false;

            if (point.x >= position.x + size.x)
                return false;
            if (point.y >= position.y + size.y)
                return false;

            return true;
        }

        public bool Intersects(Rect2 b)
        {
            if (position.x > b.position.x + b.size.x)
                return false;
            if (position.x + size.x < b.position.x)
                return false;
            if (position.y > b.position.y + b.size.y)
                return false;
            if (position.y + size.y < b.position.y)
                return false;

            return true;
        }

        public Rect2 Merge(Rect2 b)
        {
            Rect2 newRect;

            newRect.position.x = Mathf.Min(b.position.x, position.x);
            newRect.position.y = Mathf.Min(b.position.y, position.y);

            newRect.size.x = Mathf.Max(b.position.x + b.size.x, position.x + size.x);
            newRect.size.y = Mathf.Max(b.position.y + b.size.y, position.y + size.y);

            newRect.size = newRect.size - newRect.position; // Make relative again

            return newRect;
        }
        
        // Constructors 
        public Rect2(Vector2 position, Vector2 size)
        {
            this.position = position;
            this.size = size;
        }
        public Rect2(Vector2 position, real_t width, real_t height)
        {
            this.position = position;
            size = new Vector2(width, height);
        }
        public Rect2(real_t x, real_t y, Vector2 size)
        {
            position = new Vector2(x, y);
            this.size = size;
        }
        public Rect2(real_t x, real_t y, real_t width, real_t height)
        {
            position = new Vector2(x, y);
            size = new Vector2(width, height);
        }

        public static bool operator ==(Rect2 left, Rect2 right)
        {
            return left.Equals(right);
        }

        public static bool operator !=(Rect2 left, Rect2 right)
        {
            return !left.Equals(right);
        }

        public override bool Equals(object obj)
        {
            if (obj is Rect2)
            {
                return Equals((Rect2)obj);
            }

            return false;
        }

        public bool Equals(Rect2 other)
        {
            return position.Equals(other.position) && size.Equals(other.size);
        }

        public override int GetHashCode()
        {
            return position.GetHashCode() ^ size.GetHashCode();
        }

        public override string ToString()
        {
            return String.Format("({0}, {1})", new object[]
            {
                position.ToString(),
                size.ToString()
            });
        }

        public string ToString(string format)
        {
            return String.Format("({0}, {1})", new object[]
            {
                position.ToString(format),
                size.ToString(format)
            });
        }
    }
}
